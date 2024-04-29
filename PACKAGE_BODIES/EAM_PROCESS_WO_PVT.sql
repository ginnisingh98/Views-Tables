--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_WO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_WO_PVT" AS
/* $Header: EAMVWOPB.pls 120.77.12010000.32 2012/06/06 11:54:18 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOPB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_PROCESS_WO_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
--  15-May-2005	   Anju Gupta		  R12 changes for CAR/Transactable Assets
--  15-Aug-2006    Anju Gupta         Modified the call to Bottom up Scheduler
									  for bug 5408720
--  08-Sep-2011    SrikanthR          bug 12914431: Restricted the call to
                                      quality action trigger only if there
                                      are valid quality plans setup
***************************************************************************/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_PROCESS_WO_PVT';

G_EXC_QUIT_IMPORT       EXCEPTION;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_SEV_QUIT_BRANCH     EXCEPTION;
EXC_SEV_SKIP_BRANCH     EXCEPTION;
EXC_FAT_QUIT_OBJECT     EXCEPTION;
EXC_SEV_QUIT_OBJECT     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;
EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
EXC_FAT_QUIT_BRANCH     EXCEPTION;

G_FIRM_WORKORDER        CONSTANT NUMBER := 1;
G_SCHEDULE_WO           CONSTANT NUMBER := 2;
G_NOT_SCHEDULE_WO       CONSTANT NUMBER := 3;
G_NOT_BU_SCHEDULE_WO    CONSTANT NUMBER := 4;
G_BU_SCHEDULE_WO        CONSTANT NUMBER := 5;
G_NON_FIRM_WORKORDER    CONSTANT NUMBER := 6;
G_UPDATE_RES_USAGE	CONSTANT NUMBER := 7;
G_MATERIAL_UPDATE	CONSTANT NUMBER := 8;


FUNCTION IS_WORKFLOW_ENABLED
(p_maint_obj_source    IN   NUMBER,
  p_organization_id         IN    NUMBER
) RETURN VARCHAR2
IS
    l_workflow_enabled      VARCHAR2(1);
BEGIN

  BEGIN
              SELECT enable_workflow
	      INTO   l_workflow_enabled
	      FROM EAM_ENABLE_WORKFLOW
	      WHERE MAINTENANCE_OBJECT_SOURCE =p_maint_obj_source;
     EXCEPTION
          WHEN NO_DATA_FOUND   THEN
	      l_workflow_enabled    :=         'N';
   END;

  --IF EAM workorder,check if workflow is enabled for this organization or not
  IF(l_workflow_enabled ='Y'   AND   p_maint_obj_source=1) THEN
       BEGIN
               SELECT eam_wo_workflow_enabled
	       INTO l_workflow_enabled
	       FROM WIP_EAM_PARAMETERS
	       WHERE organization_id =p_organization_id;
       EXCEPTION
               WHEN NO_DATA_FOUND THEN
		       l_workflow_enabled := 'N';
       END;


     RETURN l_workflow_enabled;

  END IF;  --check for workflow enabled at org level

    RETURN l_workflow_enabled;

END IS_WORKFLOW_ENABLED;

/********************************************************************
    * Procedure: Raise_Workflow_Events
    * Parameters IN:
    *         p_api_version_number    API version
    *         p_validation_level             Validation Level
    *         p_eam_wo_rec                  Workorder rec
    *         p_raise_release_approval_event    Whether the Release Approval event has to be raised or not
    *         p_old_eam_wo_rec         Old workorder record
    * Parameters OUT:
    *         x_return_status                  Return Status
    *         x_mesg_token_tbl              Message token table
    * Purpose:
    *         This procedure raises the workflow events for workorder creation, workorder release,
    *          release approval and status change. Whether the Release Approval event has to be raised
    *           or not is determined by p_raise_release_approval_event parameter
    *********************************************************************/
 PROCEDURE RAISE_WORKFLOW_EVENTS
 ( p_api_version      IN  NUMBER
 , p_validation_level        IN  NUMBER
 , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
  ,p_old_eam_wo_rec      IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
  ,p_approval_required      IN    BOOLEAN
  ,p_new_system_status    IN    NUMBER
 , p_workflow_name    IN    VARCHAR2
 , p_workflow_process      IN   VARCHAR2
 , x_mesg_token_tbl          IN OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 , x_return_status           IN OUT NOCOPY VARCHAR2
 )
 IS
	l_create_event VARCHAR2(240);
	l_status_changed_event VARCHAR2(240);
	l_status_pending_event VARCHAR2(240);
	l_event_name VARCHAR2(240);
	l_parameter_list   wf_parameter_list_t;
	 l_event_key VARCHAR2(200);
	 l_wf_event_seq NUMBER;
	 l_estimation_status NUMBER;
	 l_cost_estimate NUMBER;
	 l_return_status    VARCHAR2(1);
	 l_err_text      VARCHAR2(2000);
	 l_msg_count     NUMBER;
 BEGIN

    l_create_event := 'oracle.apps.eam.workorder.created';
    l_status_pending_event := 'oracle.apps.eam.workorder.status.change.pending';
    l_status_changed_event := 'oracle.apps.eam.workorder.status.changed';


			--if workorder created and create event enabled
			IF(p_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE AND (WF_EVENT.TEST(l_create_event) <> 'NONE')) THEN
										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_create_event;

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Creation event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(p_eam_wo_rec.wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>p_eam_wo_rec.wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(p_eam_wo_rec.organization_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_eam_wo_rec.status_type),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value => TO_CHAR(p_eam_wo_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(p_eam_wo_rec.workflow_type),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Creation Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Creation Event','After raising event');

			END IF;  --end of check for create event enabled

			--if workorder created or user-defined status modified  or chaged from pending to non-pending
			IF(     (NVL(p_eam_wo_rec.pending_flag,'N')='N' )
			      AND
			    (  (p_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE )  --created
				OR (p_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE  --workorder updated
						     --and old status is not same as new status
						    AND (p_old_eam_wo_rec.user_defined_status_id <>p_eam_wo_rec.user_defined_status_id       OR    NVL(p_old_eam_wo_rec.pending_flag,'N')='Y' )
			    ))
			     AND (WF_EVENT.TEST(l_status_changed_event) <> 'NONE')  --if status change event enabled
			  ) THEN
										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_changed_event;

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Status change event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(p_eam_wo_rec.wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>p_eam_wo_rec.wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(p_eam_wo_rec.organization_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_eam_wo_rec.status_type),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value => TO_CHAR(p_eam_wo_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_old_eam_wo_rec.status_type),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
													    p_value => TO_CHAR(p_old_eam_wo_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(p_eam_wo_rec.workflow_type),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Staus Changed Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management..','Work Order Status Changed Event','After raising event');
			END IF;   --end of check for status change event

			--if status change needs approval
			IF( p_approval_required
			    AND (WF_EVENT.TEST(l_status_pending_event) <> 'NONE')  --event is enabled
			   ) THEN

			                                                                 --Find the total estimated cost of workorder
											   BEGIN
												 SELECT NVL((SUM(system_estimated_mat_cost) + SUM(system_estimated_lab_cost) + SUM(system_estimated_eqp_cost)),0)
												 INTO l_cost_estimate
												 FROM WIP_EAM_PERIOD_BALANCES
												 WHERE wip_entity_id = p_eam_wo_rec.wip_entity_id;
											   EXCEPTION
											      WHEN NO_DATA_FOUND THEN
												  l_cost_estimate := 0;
											   END;


										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_pending_event;

										     l_event_key := TO_CHAR(l_wf_event_seq);


										      INSERT INTO EAM_WO_WORKFLOWS
										     (WIP_ENTITY_ID,WF_ITEM_TYPE,WF_ITEM_KEY,LAST_UPDATE_DATE,LAST_UPDATED_BY,
										     CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)
										     VALUES
										     (p_eam_wo_rec.wip_entity_id,p_workflow_name,l_event_key,SYSDATE,FND_GLOBAL.user_id,
										     SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id
										     );


										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Released change event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(p_eam_wo_rec.wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>p_eam_wo_rec.wip_entity_name,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'DESCRIPTION',
													    p_value =>p_eam_wo_rec.description,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(p_eam_wo_rec.organization_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value => TO_CHAR(p_eam_wo_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_old_eam_wo_rec.status_type),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
													    p_value => TO_CHAR(p_old_eam_wo_rec.user_defined_status_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(p_new_system_status),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(p_eam_wo_rec.workflow_type),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WARRANTY_STATUS',
													    p_value => TO_CHAR(p_eam_wo_rec.warranty_claim_status),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_NAME',
													    p_value => p_workflow_name,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_PROCESS',
													    p_value => p_workflow_process,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'ESTIMATED_COST',
													    p_value => TO_CHAR(l_cost_estimate),
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Released Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Released Event','After raising event');




			END IF;  --end of check for status change pending event

 EXCEPTION
WHEN OTHERS THEN
		WF_CORE.CONTEXT('Enterprise Asset Management...',l_event_name,'Exception during event construction and raise: ' || SQLERRM);
		x_return_status := FND_API.G_RET_STS_ERROR;
 END RAISE_WORKFLOW_EVENTS;



PROCEDURE UPDATE_INTERMEDIA_INDEX
(
   p_eam_wo_rec             IN     EAM_PROCESS_WO_PUB.eam_wo_rec_type,
   p_old_eam_wo_rec     IN     EAM_PROCESS_WO_PUB.eam_wo_rec_type,
   p_eam_op_tbl               IN     EAM_PROCESS_WO_PUB.eam_op_tbl_type,
   p_eam_res_tbl              IN      EAM_PROCESS_WO_PUB.eam_res_tbl_type,
   p_eam_res_inst_tbl      IN       EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
)
IS
    l_update_index     BOOLEAN;
BEGIN
     l_update_index := FALSE;


     IF(p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE)
        THEN

										     EAM_TEXT_UTIL.PROCESS_WO_EVENT
										     (
										          p_event  => 'INSERT',
											  p_wip_entity_id =>p_eam_wo_rec.wip_entity_id,
											  p_organization_id =>p_eam_wo_rec.organization_id,
											  p_last_update_date  => SYSDATE,
											  p_last_updated_by  => FND_GLOBAL.user_id,
											  p_last_update_login =>FND_GLOBAL.login_id
										     );
		RETURN;
     END IF;

         IF (p_eam_wo_rec.transaction_type = G_OPR_UPDATE AND
	     ((NVL(p_eam_wo_rec.description,'') <> NVL(p_old_eam_wo_rec.description,''))  OR
	         (p_eam_wo_rec.maintenance_object_id <> p_old_eam_wo_rec.maintenance_object_id) OR
		 (p_eam_wo_rec.user_defined_status_id <> p_old_eam_wo_rec.user_defined_status_id) OR
		 (NVL(p_eam_wo_rec.asset_activity_id,-1) <> NVL(p_old_eam_wo_rec.asset_activity_id,-1))
		 OR (NVL(p_eam_wo_rec.owning_department,-1) <> NVL(p_old_eam_wo_rec.owning_department,-1))
		 OR (NVL(p_eam_wo_rec.project_id,-1) <> NVL(p_old_eam_wo_rec.project_id,-1))
		 OR (NVL(p_eam_wo_rec.task_id,-1) <> NVL(p_old_eam_wo_rec.task_id,-1))
		 OR (NVL(p_eam_wo_rec.priority,-1) <> NVL(p_old_eam_wo_rec.priority,-1))
		 OR (NVL(p_eam_wo_rec.work_order_type,'') <> NVL(p_old_eam_wo_rec.work_order_type,''))
		 OR (NVL(p_eam_wo_rec.activity_type,'') <> NVL(p_old_eam_wo_rec.activity_type,''))
		 OR (NVL(p_eam_wo_rec.activity_cause,'') <> NVL(p_old_eam_wo_rec.activity_cause,''))
		 OR (NVL(p_eam_wo_rec.activity_source,'') <> NVL(p_old_eam_wo_rec.activity_source,''))
	     )
	 ) THEN
	    l_update_index := TRUE;
      END IF;

      IF(l_update_index = FALSE) THEN
            IF(p_eam_op_tbl IS NOT NULL AND p_eam_op_tbl.COUNT>0) THEN
                        FOR i IN  p_eam_op_tbl.FIRST ..  p_eam_op_tbl.LAST LOOP
                                    IF(p_eam_op_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
				                            OR p_eam_op_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_DELETE) THEN
							    l_update_index:=TRUE;
							    EXIT;
                                    END IF;
                         END LOOP;
         END IF;
      END IF;

       IF(l_update_index = FALSE) THEN
            IF(p_eam_res_tbl IS NOT NULL AND p_eam_res_tbl.COUNT>0) THEN
                        FOR i IN  p_eam_res_tbl.FIRST ..  p_eam_res_tbl.LAST LOOP
                                    IF(p_eam_res_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
				                            OR p_eam_res_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_DELETE) THEN
							    l_update_index:=TRUE;
							    EXIT;
                                    END IF;
                         END LOOP;
         END IF;
      END IF;

       IF(l_update_index = FALSE) THEN
            IF(p_eam_res_inst_tbl IS NOT NULL AND p_eam_res_inst_tbl.COUNT>0) THEN
                        FOR i IN  p_eam_res_inst_tbl.FIRST ..  p_eam_res_inst_tbl.LAST LOOP
                                    IF(p_eam_res_inst_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
				                            OR p_eam_res_inst_tbl(i).transaction_type = EAM_PROCESS_WO_PUB.G_OPR_DELETE) THEN
							    l_update_index:=TRUE;
							    EXIT;
                                    END IF;
                         END LOOP;
         END IF;
      END IF;

      IF(l_update_index = TRUE) THEN
										     EAM_TEXT_UTIL.PROCESS_WO_EVENT
										     (
										          p_event  => 'UPDATE',
											  p_wip_entity_id =>p_eam_wo_rec.wip_entity_id,
											  p_organization_id =>p_eam_wo_rec.organization_id,
											  p_last_update_date  => SYSDATE,
											  p_last_updated_by  => FND_GLOBAL.user_id,
											  p_last_update_login =>FND_GLOBAL.login_id
										     );
      END IF;

END UPDATE_INTERMEDIA_INDEX;




PROCEDURE RESOURCE_USAGES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
	,  p_resource_seq_num        IN  NUMBER := NULL
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_res_usage_rec     EAM_PROCESS_WO_PUB.eam_res_usage_rec_type ;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
l_eam_sub_res_rec      EAM_PROCESS_WO_PUB.eam_sub_res_rec_type ;
l_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type ;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type ;

        l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
        l_out_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;


BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.RESOURCE_USAGES : Start=== '||p_eam_res_usage_tbl.COUNT ||' records passed =======================') ; END IF ;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_res_usage_tbl:= p_eam_res_usage_tbl ;


   FOR I IN 1..l_eam_res_usage_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_res_usage_rec := l_eam_res_usage_tbl(I);

      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;


      IF l_eam_res_usage_rec.wip_entity_id is NULL
         AND (l_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_res_usage_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL AND
         p_operation_seq_num IS NOT NULL AND
	 p_resource_seq_num IS NOT NULL
      THEN
         l_parent_exists := TRUE;
      END IF;

      -- Check if record has not yet been processed and that it is the child of the parent that called this procedure

      IF (l_eam_res_usage_rec.return_status IS NULL OR l_eam_res_usage_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_res_usage_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_res_usage_rec.organization_id = p_organization_id AND
              l_eam_res_usage_rec.operation_seq_num = p_operation_seq_num AND
	      l_eam_res_usage_rec.resource_seq_num = p_resource_seq_num
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;


         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_res_usage_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_res_usage_rec.transaction_type
        ,   p_entity_name       => 'RESOURCE_SEQ_NUM'
        ,   p_entity_id         => to_char(l_eam_res_usage_rec.resource_seq_num)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;


         EAM_RES_USAGE_VALIDATE_PVT.Check_Required
         ( p_eam_res_usage_rec          => l_eam_res_usage_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_RU_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
               l_other_token_tbl(1).token_value := l_eam_res_usage_rec.resource_seq_num ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_RU_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_other_token_tbl(1).token_value := l_eam_res_usage_rec.resource_seq_num ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_RES_USAGE_VALIDATE_PVT.Check_Attributes
            ( p_eam_res_usage_rec    => l_eam_res_usage_rec
            , x_return_status        => l_return_status
            , x_mesg_token_tbl       => l_mesg_token_tbl
            );

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_RU_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
                  l_other_token_tbl(1).token_value := l_eam_res_usage_rec.resource_seq_num ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_RU_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
               l_other_token_tbl(1).token_value := l_eam_res_usage_rec.resource_seq_num ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

           END IF;

	/* Bug 5224748. Call Add_usage only for non firm work orders. For firm wos, Bottom Up should handle the insertions*/
	IF ( x_bottomup_scheduled = G_NON_FIRM_WORKORDER ) THEN

          EAM_RES_USAGE_UTILITY_PVT.Add_Usage
          (  p_eam_res_usage_rec   => l_eam_res_usage_rec
          ,  x_mesg_token_tbl      => l_mesg_token_tbl
          ,  x_return_status       => l_return_status
          );


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_RU_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
          l_other_token_tbl(1).token_value := l_eam_res_usage_rec.resource_seq_num ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
            l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Resources Database writes completed with status  ' || l_return_status); END IF;
   END IF ; -- bug 5224748. end of check for x_bottomup_scheduled = G_NON_FIRM_WORKORDER

 ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

    --find if bottom up scheduler is to be called or not

	     IF(l_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE   -- is resource usage is added
	             OR (l_eam_res_usage_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_DELETE ) --deleted
		     OR (l_eam_res_usage_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND  --updating the resource usage

		       (
		       --NVL(l_eam_res_rec.schedule_seq_num,l_eam_res_rec.resource_seq_num)<>NVL(l_old_eam_res_rec.schedule_seq_num,l_old_eam_res_rec.resource_seq_num)
		        -- OR
			l_eam_res_usage_rec.start_date <> l_eam_res_usage_rec.old_start_date   --shedule_seq_num,start_date,completion_date
			OR l_eam_res_usage_rec.completion_date <> l_eam_res_usage_rec.old_completion_date
		--	OR l_eam_res_rec.resource_id <> l_old_eam_res_rec.resource_id    --resource_code,usage_rate_or_amount,scheduled_flag,assigned_units
		--	OR l_eam_res_rec.usage_rate_or_amount <> l_old_eam_res_rec.usage_rate_or_amount
		--	OR l_eam_res_rec.scheduled_flag <> l_old_eam_res_rec.scheduled_flag
		--	OR NVL(l_eam_res_rec.assigned_units,0) <> NVL(l_old_eam_res_rec.assigned_units,0)
			)
		    )
		) THEN
		     x_bottomup_scheduled := G_UPDATE_RES_USAGE;
	     END IF;

    --  Load tables.
    l_eam_res_usage_tbl(I)          := l_eam_res_usage_rec;


    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_usage_tbl              := l_eam_res_usage_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_usage_tbl              := l_eam_res_usage_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;


         l_process_children             := FALSE ;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_usage_tbl              := l_eam_res_usage_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_USAGE_tbl              := l_eam_res_USAGE_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_usage_tbl              := l_eam_res_usage_tbl;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_usage_tbl              := l_eam_res_usage_tbl;


      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_USAGE_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_usage_tbl              := l_eam_res_usage_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   END LOOP; -- END Resources processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.RESOURCE_USAGES : End ==== Return status: '||NVL(l_return_status, 'S')||' =======================') ; END IF ;

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;


        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eam_res_usage_tbl              := l_eam_res_usage_tbl;

END RESOURCE_USAGES;














PROCEDURE SUB_RESOURCES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_sub_res_rec      EAM_PROCESS_WO_PUB.eam_sub_res_rec_type ;
l_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type ;
l_old_eam_sub_res_rec  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type ;

l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
l_out_eam_sub_res_rec   EAM_PROCESS_WO_PUB.eam_sub_res_rec_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;


BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.SUB_RESOURCES : Start=== '||p_eam_sub_res_tbl.COUNT ||' records passed =======================') ; END IF ;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_sub_res_tbl  := p_eam_sub_res_tbl ;


   FOR I IN 1..l_eam_sub_res_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_sub_res_rec := l_eam_sub_res_tbl(I);

      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;



      IF l_eam_sub_res_rec.wip_entity_id is NULL
         AND (l_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_sub_res_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL AND
         p_operation_seq_num IS NOT NULL
      THEN
         l_parent_exists := TRUE;
      END IF;

      -- Check if record has not yet been processed and that it is the child of the parent that called this procedure

      IF (l_eam_sub_res_rec.return_status IS NULL OR l_eam_sub_res_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_sub_res_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_sub_res_rec.organization_id = p_organization_id AND
              l_eam_sub_res_rec.operation_seq_num = p_operation_seq_num
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;


         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_sub_res_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_sub_res_rec.transaction_type
        ,   p_entity_name       => 'RESOURCE_SEQ_NUM'
        ,   p_entity_id         => to_char(l_eam_sub_res_rec.resource_seq_num)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         EAM_SUB_RESOURCE_VALIDATE_PVT.Check_Existence
         (  p_eam_sub_res_rec       => l_eam_sub_res_rec
         ,  x_old_eam_sub_res_rec   => l_old_eam_sub_res_rec
         ,  x_mesg_token_tbl             => l_mesg_token_tbl
         ,  x_return_status              => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_SR_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_sub_res_rec.wip_entity_id;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_SR_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_sub_res_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_sub_res_rec.transaction_type := l_old_eam_sub_res_rec.transaction_type;
        END IF;


        IF l_eam_sub_res_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;

           l_out_eam_sub_res_rec := l_eam_sub_res_rec;

           EAM_SUB_RESOURCE_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_sub_res_rec        => l_eam_sub_res_rec
           ,   p_old_eam_sub_res_Rec    => l_old_eam_sub_res_rec
           ,   x_eam_sub_res_rec     => l_out_eam_sub_res_rec
           ) ;

           l_eam_sub_res_rec := l_out_eam_sub_res_rec;


        ELSIF l_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN

           l_out_eam_sub_res_rec := l_eam_sub_res_rec;

           EAM_SUB_RESOURCE_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_sub_res_rec   => l_eam_sub_res_rec
           ,   x_eam_sub_res_rec   => l_out_eam_sub_res_rec
           ,   x_mesg_token_tbl  => l_mesg_token_tbl
           ,   x_return_status   => l_return_status
           ) ;

           l_eam_sub_res_rec := l_out_eam_sub_res_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_SR_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
              l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_SR_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
              l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
              l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
              l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
          END IF;
       END IF;


         EAM_SUB_RESOURCE_VALIDATE_PVT.Check_Required
         ( p_eam_sub_res_rec           => l_eam_sub_res_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_SR_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
               l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_SR_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_SUB_RESOURCE_VALIDATE_PVT.Check_Attributes
            ( p_eam_sub_res_rec     => l_eam_sub_res_rec
            , p_old_eam_sub_res_rec => l_old_eam_sub_res_rec
            , x_return_status        => l_return_status
            , x_mesg_token_tbl       => l_mesg_token_tbl
            ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_SR_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
                  l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_SR_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
               l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
              l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
              l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

           END IF;

          EAM_SUB_RESOURCE_UTILITY_PVT.Perform_Writes
          (   p_eam_sub_res_rec          => l_eam_sub_res_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_SR_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RESOURCE_SEQ_NUM';
          l_other_token_tbl(1).token_value := l_eam_sub_res_rec.resource_seq_num ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
            l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
            l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
            l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Resources Database writes completed with status  ' || l_return_status); END IF;

    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_eam_sub_res_tbl(I)          := l_eam_sub_res_rec;


    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
        l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;


         l_process_children             := FALSE ;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;

         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;

         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;


      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_SUB_RES_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;



   IF l_process_children
   THEN


      -- Process Resource Usage that are direct children of this
      -- operation
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling RESOURCE_USAGES from SUB_RESOURCE') ; END IF ;

        l_out_eam_res_usage_tbl := l_eam_res_usage_tbl;

        RESOURCE_USAGES
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_sub_res_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_sub_res_rec.organization_id
        ,  p_operation_seq_num             =>  l_eam_sub_res_rec.operation_seq_num
        ,  p_resource_seq_num              =>  l_eam_sub_res_rec.resource_seq_num
        ,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
        ,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
	,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_res_usage_tbl := l_out_eam_res_usage_tbl;

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

   END IF;   -- Process children


   END LOOP; -- END Resources processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.SUB_RESOURCES : End ==== Return status: '||NVL(l_return_status, 'S')||' =======================') ; END IF ;

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;


        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;

END SUB_RESOURCES;




















PROCEDURE RESOURCE_INSTANCES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_resource_seq_num        IN  NUMBER := NULL
        ,  p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        )
IS

l_eam_res_inst_rec      EAM_PROCESS_WO_PUB.eam_res_inst_rec_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
l_old_eam_res_inst_rec  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type ;

l_out_eam_res_inst_rec      EAM_PROCESS_WO_PUB.eam_res_inst_rec_type ;
l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
l_out_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type ;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type ;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;

l_eam_res_usage_rec	EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;


BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.RESOURCE_INSTANCES : Start=== '||p_eam_res_inst_tbl.COUNT ||' records passed ================') ; END IF ;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF x_bottomup_scheduled = G_NON_FIRM_WORKORDER THEN
		  x_schedule_wo := G_SCHEDULE_WO;
	END IF;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_res_inst_tbl    := p_eam_res_inst_tbl ;


   FOR I IN 1..l_eam_res_inst_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_res_inst_rec := l_eam_res_inst_tbl(I);

      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;


      IF l_eam_res_inst_rec.wip_entity_id is NULL
         AND (l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_res_inst_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL AND
         p_operation_seq_num IS NOT NULL AND
         p_resource_seq_num IS NOT NULL
      THEN
         l_parent_exists := TRUE;
      END IF;

      -- Check if record has not yet been processed and that it is the child of the parent that called this procedure

      IF (l_eam_res_inst_rec.return_status IS NULL OR l_eam_res_inst_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_res_inst_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_res_inst_rec.organization_id = p_organization_id AND
              l_eam_res_inst_rec.operation_seq_num = p_operation_seq_num AND
              l_eam_res_inst_rec.resource_seq_num = p_resource_seq_num
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_res_inst_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_res_inst_rec.transaction_type
        ,   p_entity_name       => 'RESOURCE_INSTANCE'
        ,   p_entity_id         => to_char(l_eam_res_inst_rec.instance_id)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         EAM_RES_INST_VALIDATE_PVT.Check_Existence
         (  p_eam_res_inst_rec       => l_eam_res_inst_rec
         ,  x_old_eam_res_inst_rec   => l_old_eam_res_inst_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_RI_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_res_inst_rec.wip_entity_id;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_RI_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_res_inst_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_res_inst_rec.transaction_type := l_old_eam_res_inst_rec.transaction_type;
        END IF;


        IF l_eam_res_inst_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;


           l_out_eam_res_inst_rec := l_eam_res_inst_rec;
           EAM_RES_INST_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_res_inst_rec        => l_eam_res_inst_rec
           ,   p_old_eam_res_inst_Rec    => l_old_eam_res_inst_rec
           ,   x_eam_res_inst_rec     => l_out_eam_res_inst_rec
           ) ;
           l_eam_res_inst_rec := l_out_eam_res_inst_rec;


        ELSIF l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN

           l_out_eam_res_inst_rec := l_eam_res_inst_rec;
           EAM_RES_INST_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_res_inst_rec   => l_eam_res_inst_rec
           ,   x_eam_res_inst_rec   => l_out_eam_res_inst_rec
           ,   x_mesg_token_tbl  => l_mesg_token_tbl
           ,   x_return_status   => l_return_status
           ) ;
           l_eam_res_inst_rec := l_out_eam_res_inst_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_RI_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name  := 'INSTANCE_ID';
              l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_RI_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'INSTANCE_ID';
              l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
          END IF;
       END IF;


         EAM_RES_INST_VALIDATE_PVT.Check_Required
         ( p_eam_res_inst_rec           => l_eam_res_inst_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_RI_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'INSTANCE_ID';
               l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_RI_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_RES_INST_VALIDATE_PVT.Check_Attributes
            ( p_eam_res_inst_rec     => l_eam_res_inst_rec
            , p_old_eam_res_inst_rec => l_old_eam_res_inst_rec
            , x_return_status        => l_return_status
            , x_mesg_token_tbl       => l_mesg_token_tbl
            ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_RI_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'INSTANCE_ID';
                  l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_RI_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'INSTANCE_ID';
               l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_res_inst_tbl := l_eam_res_inst_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_res_inst_tbl := l_out_eam_res_inst_tbl;

           END IF;


          EAM_RES_INST_UTILITY_PVT.Perform_Writes
          (   p_eam_res_inst_rec    => l_eam_res_inst_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;

/*	  IF l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
	  AND x_bottomup_scheduled <> G_NON_FIRM_WORKORDER
	  THEN


	l_eam_res_usage_rec.header_id		:=	l_eam_res_inst_rec.header_id;
	l_eam_res_usage_rec.batch_id		:=	l_eam_res_inst_rec.batch_id;
	l_eam_res_usage_rec.row_id		:=	l_eam_res_inst_rec.row_id;
	l_eam_res_usage_rec.wip_entity_id	:=	l_eam_res_inst_rec.wip_entity_id;
	l_eam_res_usage_rec.operation_seq_num	:=	l_eam_res_inst_rec.operation_seq_num;
	l_eam_res_usage_rec.resource_seq_num	:=	l_eam_res_inst_rec.resource_seq_num;
	l_eam_res_usage_rec.organization_id	:=	l_eam_res_inst_rec.organization_id;
	l_eam_res_usage_rec.start_date		:=	l_eam_res_inst_rec.start_date;
	l_eam_res_usage_rec.assigned_units	:=      1;
	l_eam_res_usage_rec.completion_date	:=	l_eam_res_inst_rec.completion_date;
	l_eam_res_usage_rec.instance_id         :=      l_eam_res_inst_rec.instance_id;
	l_eam_res_usage_rec.serial_number	:=      l_eam_res_inst_rec.serial_number;
	l_eam_res_usage_rec.return_status	:=      l_eam_res_inst_rec.return_status;
	l_eam_res_usage_rec.transaction_type    :=      l_eam_res_inst_rec.transaction_type;

		 EAM_RES_USAGE_UTILITY_PVT.Add_Usage
		  (  p_eam_res_usage_rec   => l_eam_res_usage_rec
		  ,  x_mesg_token_tbl      => l_mesg_token_tbl
		  ,  x_return_status       => l_return_status
		  );
	  END IF;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_RI_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'INSTANCE_ID';
          l_other_token_tbl(1).token_value := l_eam_res_inst_rec.instance_id ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
       END IF;
       */

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Resources Database writes completed with status  ' || l_return_status); END IF;

    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

     --find if bottom up scheduler is to be called or not

	 IF(x_bottomup_scheduled = G_NOT_BU_SCHEDULE_WO)THEN    --not yet set to schedule
	     IF(l_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE   -- is resource iinstance is added
	    --    OR (l_eam_res_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_DELETE AND l_eam_res_rec.scheduled_flag=1) --deleted and was scheduled
		OR (l_eam_res_inst_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND  --updating the resource iinstance
		       (
		       --NVL(l_eam_res_rec.schedule_seq_num,l_eam_res_rec.resource_seq_num)<>NVL(l_old_eam_res_rec.schedule_seq_num,l_old_eam_res_rec.resource_seq_num)
		        -- OR
			l_eam_res_inst_rec.start_date <> l_old_eam_res_inst_rec.start_date   --shedule_seq_num,start_date,completion_date
			OR l_eam_res_inst_rec.completion_date <> l_old_eam_res_inst_rec.completion_date
		--	OR l_eam_res_rec.resource_id <> l_old_eam_res_rec.resource_id    --resource_code,usage_rate_or_amount,scheduled_flag,assigned_units
		--	OR l_eam_res_rec.usage_rate_or_amount <> l_old_eam_res_rec.usage_rate_or_amount
		--	OR l_eam_res_rec.scheduled_flag <> l_old_eam_res_rec.scheduled_flag
		--	OR NVL(l_eam_res_rec.assigned_units,0) <> NVL(l_old_eam_res_rec.assigned_units,0)
			)
		    )
		) THEN
		    x_bottomup_scheduled := G_UPDATE_RES_USAGE;
	     END IF;
	 END IF;


    --  Load tables.
    l_eam_res_inst_tbl(I)          := l_eam_res_inst_rec;


    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;

         l_process_children             := FALSE;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;



      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_INST_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   END LOOP; -- END Resources processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.RESOURCE_INSTANCES : End ==== Return status: '||NVL(l_return_status, 'S')||' =======================') ; END IF ;


   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
   x_return_status     := l_return_status;
   END IF;
   x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


END RESOURCE_INSTANCES;















PROCEDURE OPERATION_NETWORKS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        ,  x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_op_network_rec       EAM_PROCESS_WO_PUB.eam_op_network_rec_type ;
l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;
l_old_eam_op_network_rec   EAM_PROCESS_WO_PUB.eam_op_network_rec_type ;

l_out_eam_op_network_rec       EAM_PROCESS_WO_PUB.eam_op_network_rec_type ;
l_out_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type ;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type ;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;


BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.OPERATION_NETWORKS : Start=== '||p_eam_op_network_tbl.COUNT ||' records passed =======================') ; END IF ;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_op_network_tbl    := p_eam_op_network_tbl ;


   FOR I IN 1..l_eam_op_network_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.

      l_eam_op_network_rec := l_eam_op_network_tbl(I);

      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;

      IF l_eam_op_network_rec.wip_entity_id is NULL
         AND (l_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE)
      THEN
          l_eam_op_network_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL
      THEN
         l_parent_exists := TRUE;
      END IF;

      -- Check if record has not yet been processed and that it is the child of the parent that called this procedure

      IF (l_eam_op_network_rec.return_status IS NULL OR l_eam_op_network_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_op_network_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_op_network_rec.organization_id = p_organization_id
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_op_network_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_op_network_rec.transaction_type
        ,   p_entity_name       => 'OPERATION_NETWORK'
        ,   p_entity_id         => to_char(l_eam_op_network_rec.prior_operation)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         EAM_OP_NETWORK_VALIDATE_PVT.Check_Existence
         (  p_eam_op_network_rec     => l_eam_op_network_rec
         ,  x_old_eam_op_network_rec => l_old_eam_op_network_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_OPN_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_op_network_rec.wip_entity_id;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_OPN_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_op_network_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_op_network_rec.transaction_type := l_old_eam_op_network_rec.transaction_type;
        END IF;


        IF l_eam_op_network_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;

           l_out_eam_op_network_rec := l_eam_op_network_rec;

           EAM_OP_NETWORK_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_op_network_rec        => l_eam_op_network_rec
           ,   p_old_eam_op_network_rec    => l_old_eam_op_network_rec
           ,   x_eam_op_network_rec     => l_out_eam_op_network_rec
           ) ;

           l_eam_op_network_rec := l_out_eam_op_network_rec;


        ELSIF l_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN

           l_out_eam_op_network_rec := l_eam_op_network_rec;

           EAM_OP_NETWORK_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_op_network_rec   => l_eam_op_network_rec
           ,   x_eam_op_network_rec   => l_out_eam_op_network_rec
           ,   x_mesg_token_tbl  => l_mesg_token_tbl
           ,   x_return_status   => l_return_status
           ) ;

           l_eam_op_network_rec := l_out_eam_op_network_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_OPN_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
              l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_OPN_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
              l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
          END IF;
       END IF;


         EAM_OP_NETWORK_VALIDATE_PVT.Check_Required
         ( p_eam_op_network_rec         => l_eam_op_network_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_OPN_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
               l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_OPN_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_OP_NETWORK_VALIDATE_PVT.Check_Attributes
            ( p_eam_op_network_rec        => l_eam_op_network_rec
            , p_old_eam_op_network_rec    => l_old_eam_op_network_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_OPN_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
                  l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_OPN_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name  := 'PRIOR_OPERATION';
               l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_op_network_tbl    := l_out_eam_op_network_tbl;

           END IF;


          EAM_OP_NETWORK_UTILITY_PVT.Perform_Writes
          (   p_eam_op_network_rec  => l_eam_op_network_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_OPN_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'PRIOR_OPERATION';
          l_other_token_tbl(1).token_value := l_eam_op_network_rec.prior_operation ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
            l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
       END IF;

	--find if scheduler is to be called or not
	      IF(x_schedule_wo = G_NOT_SCHEDULE_WO
		 AND l_eam_op_network_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_CREATE,EAM_PROCESS_WO_PVT.G_OPR_DELETE)
		 ) THEN     -- if op dependency is added or deleted
		    x_schedule_wo := G_SCHEDULE_WO;
	      END IF;

	--find if bottum up scheduler is to be called or not
	      IF(x_bottomup_scheduled = G_NOT_BU_SCHEDULE_WO
		 AND l_eam_op_network_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_CREATE,EAM_PROCESS_WO_PVT.G_OPR_DELETE)
		 ) THEN     -- if op dependency is added or deleted
		    x_bottomup_scheduled := G_BU_SCHEDULE_WO;
	      END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Networks Database writes completed with status  ' || l_return_status); END IF;

    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_eam_op_network_tbl(I)          := l_eam_op_network_rec;


    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
        l_eam_op_network_tbl    := l_out_eam_op_network_tbl;

         l_process_children             := FALSE;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_op_network_tbl    := l_out_eam_op_network_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_op_network_tbl    := l_out_eam_op_network_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_op_network_tbl    := l_out_eam_op_network_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_op_network_tbl    := l_out_eam_op_network_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;



      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_op_network_tbl    := l_out_eam_op_network_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;


      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_NETWORK_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_op_network_tbl    := l_out_eam_op_network_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   END LOOP; -- END Operation Networks processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.OPERATION_NETWORKS : End ==== Return status: '||NVL(l_return_status, 'S')||' ================') ; END IF ;

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;

END OPERATION_NETWORKS;






PROCEDURE MATERIAL_REQUIREMENTS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_department_id           IN  NUMBER := NULL
        ,  p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
	,  x_material_shortage       IN OUT NOCOPY NUMBER
        ,  x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_mat_req_rec       EAM_PROCESS_WO_PUB.eam_mat_req_rec_type ;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_old_eam_mat_req_rec   EAM_PROCESS_WO_PUB.eam_mat_req_rec_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_old_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type ;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

l_out_eam_mat_req_rec   EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_pick_return_status    VARCHAR2(1) ;
l_msg_count             NUMBER := 0;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;
l_organization_id        NUMBER := p_organization_id ;
l_wip_entity_id           NUMBER := p_wip_entity_id ;
l_operation_seq_num    NUMBER := p_operation_seq_num ;
l_wo_status            NUMBER;
l_api_return_status    VARCHAR2(1);
l_api_msg_count        NUMBER;
l_api_msg_data         VARCHAR2(100);

l_uom_code             VARCHAR2(10);
l_description          VARCHAR2(240);
l_non_stock_flag       VARCHAR2(2);
l_purch_flag           VARCHAR2(2);
l_purch_cat_id         NUMBER;
l_req_number           NUMBER;
l_total_req_qty        NUMBER;
l_po_ordered_qty       NUMBER;
l_req_qty              NUMBER;
l_inv_item_name        VARCHAR2(240);
l_wip_entity_name      VARCHAR2(20);
l_req_for_cancel_qty_profile VARCHAR2(1);


BEGIN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.MATERIAL_REQUIREMENTS : Start ====='||p_eam_mat_req_tbl.COUNT ||' records passed'||' ========') ; END IF ;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_mat_req_tbl    := p_eam_mat_req_tbl ;



	/* Get the materials in the Operation 1 and append to the table l_eam_mat_req_tbl */
   IF ( p_operation_seq_num IS NOT NULL
      and EAM_MAT_REQ_UTILITY_PVT.NUM_OF_ROW
       (  p_organization_id   => l_organization_id
        , p_wip_entity_id     => l_wip_entity_id
        , p_operation_seq_num => 1
       )  in  (TRUE)) THEN

       l_out_eam_mat_req_tbl := l_eam_mat_req_tbl ;
       EAM_MAT_REQ_DEFAULT_PVT.GetMaterials_In_Op1
	   (  p_eam_mat_req_tbl => l_eam_mat_req_tbl
	    , p_organization_id => l_organization_id
		, p_wip_entity_id => l_wip_entity_id
		, x_eam_mat_req_tbl => l_out_eam_mat_req_tbl
       );
	   l_eam_mat_req_tbl := l_out_eam_mat_req_tbl ;


  END IF;


   FOR I IN 1..l_eam_mat_req_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_mat_req_rec := l_eam_mat_req_tbl(I);

      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;


      IF l_eam_mat_req_rec.wip_entity_id is NULL
         AND (l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL AND
         p_operation_seq_num IS NOT NULL AND
         p_department_id IS NOT NULL
      THEN
         l_parent_exists := TRUE;
         l_eam_mat_req_rec.department_id := p_department_id;
      END IF;

	--bug 14000059
      IF(l_eam_mat_req_rec.suggested_vendor_name  is not null and l_eam_mat_req_rec.vendor_id is null) THEN
      BEGIN
        SELECT vendor_id INTO l_eam_mat_req_rec.vendor_id
        FROM   po_suppliers_val_v
        WHERE upper(vendor_name) = upper(l_eam_mat_req_rec.suggested_vendor_name );
      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;
      END IF;


      -- Check if record has not yet been processed and that it is the child of the parent that called this procedure

      IF (l_eam_mat_req_rec.return_status IS NULL OR l_eam_mat_req_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_mat_req_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_mat_req_rec.organization_id = p_organization_id AND
              (l_eam_mat_req_rec.operation_seq_num = p_operation_seq_num OR
               l_eam_mat_req_rec.operation_seq_num = 1
              )
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_mat_req_rec.return_status := FND_API.G_RET_STS_SUCCESS;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating Transaction Type') ; END IF ;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_mat_req_rec.transaction_type
        ,   p_entity_name       => 'MATERIAL_REQUIREMENTS'
        ,   p_entity_id         => to_char(l_eam_mat_req_rec.inventory_item_id)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking Existence of Record') ; END IF ;

         EAM_MAT_REQ_VALIDATE_PVT.Check_Existence
         (  p_eam_mat_req_rec            => l_eam_mat_req_rec
         ,  x_old_eam_mat_req_rec        => l_old_eam_mat_req_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_MR_EXS_SEV_SKIP';
	    --Start bug# 11672256
            SELECT segment1 INTO l_inv_item_name FROM mtl_system_items WHERE inventory_item_id=l_eam_mat_req_rec.inventory_item_id AND organization_id=l_eam_mat_req_rec.organization_id;
            l_other_token_tbl(1).token_name  := 'INV_ITEM_NAME';
            l_other_token_tbl(1).token_value := l_inv_item_name;
            SELECT wip_entity_name INTO l_wip_entity_name FROM wip_entities WHERE wip_entity_id=l_eam_mat_req_rec.wip_entity_id;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_NAME';
            l_other_token_tbl(2).token_value := l_wip_entity_name;
	    -- End bug# 11672256
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_MR_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'INV_ITEM_ID';
            l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_mat_req_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_mat_req_rec.transaction_type := l_old_eam_mat_req_rec.transaction_type;
        END IF;


        IF l_eam_mat_req_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

  	   IF l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE THEN
		   x_material_shortage := G_MATERIAL_UPDATE;
	   END IF;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;

           l_out_eam_mat_req_rec := l_eam_mat_req_rec;

           EAM_MAT_REQ_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_mat_req_rec        => l_eam_mat_req_rec
           ,   p_old_eam_mat_req_Rec    => l_old_eam_mat_req_rec
           ,   x_eam_mat_req_rec     => l_out_eam_mat_req_rec
           ) ;

           l_eam_mat_req_rec := l_out_eam_mat_req_rec;


		    IF ( p_operation_seq_num IS NOT NULL
	              and l_eam_mat_req_rec.operation_seq_num = 1 ) THEN

                 l_out_eam_mat_req_rec := l_eam_mat_req_rec;

                 EAM_MAT_REQ_DEFAULT_PVT.Change_OpSeqNum1
                 (    p_eam_mat_req_rec    => l_eam_mat_req_rec
                    , p_operation_seq_num  =>  p_operation_seq_num
                    , p_department_id => p_department_id
                    , x_eam_mat_req_rec =>  l_out_eam_mat_req_rec
                 ) ;

                 l_eam_mat_req_rec := l_out_eam_mat_req_rec;
            END IF;

        ELSIF l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN

	   x_material_shortage := G_MATERIAL_UPDATE;

           l_out_eam_mat_req_rec := l_eam_mat_req_rec;

           EAM_MAT_REQ_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_mat_req_rec   => l_eam_mat_req_rec
           ,   x_eam_mat_req_rec   => l_out_eam_mat_req_rec
           ,   x_mesg_token_tbl    => l_mesg_token_tbl
           ,   x_return_status     => l_return_status
           ) ;

           l_eam_mat_req_rec := l_out_eam_mat_req_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_MR_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name  := 'Inventory_Item';
--              l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;

	 SELECT concatenated_segments into l_token_tbl(1).token_value
	 FROM  mtl_system_items_kfv msik
	 WHERE 	 msik.inventory_item_id = l_eam_mat_req_rec.inventory_item_id
 	 AND     msik.organization_id   = l_eam_mat_req_rec.organization_id;

              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_MR_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'INV_ITEM_ID';
              l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
          END IF;
       END IF;


         EAM_MAT_REQ_VALIDATE_PVT.Check_Required
         ( p_eam_mat_req_rec                => l_eam_mat_req_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_MR_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'INV_ITEM_ID';
               l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_MR_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'INV_ITEM_ID';
            l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_MAT_REQ_VALIDATE_PVT.Check_Attributes
            ( p_eam_mat_req_rec        => l_eam_mat_req_rec
            , p_old_eam_mat_req_rec    => l_old_eam_mat_req_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

	IF l_old_eam_mat_req_rec.REQUIRED_QUANTITY <> l_eam_mat_req_rec.REQUIRED_QUANTITY THEN
		x_material_shortage := G_MATERIAL_UPDATE;
	END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_MR_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'INV_ITEM_ID';
                  l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_MR_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'INV_ITEM_ID';
               l_other_token_tbl(1).token_value := l_eam_mat_req_rec.inventory_item_id ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               ( p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;

           END IF;



          EAM_MAT_REQ_UTILITY_PVT.Perform_Writes
          (   p_eam_mat_req_rec          => l_eam_mat_req_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_MR_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'INV_ITEM_ID';
          l_other_token_tbl(1).token_value :=
                          l_eam_mat_req_rec.inventory_item_id ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               ( p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
       END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Material Requirements Database writes completed with status  ' || l_return_status); END IF;


       -- Stock Issue requirements
       EAM_WO_UTILITY_PVT.Query_Row(
           p_wip_entity_id       => l_eam_mat_req_rec.wip_entity_id
         , p_organization_id     => l_eam_mat_req_rec.organization_id
         , x_eam_wo_rec          => l_old_eam_wo_rec
         , x_Return_status       => l_return_status
       );
--Bug4188160:pass item description instead of item name
       select primary_uom_code, stock_enabled_flag,
         purchasing_item_flag, description
         into l_uom_code, l_non_stock_flag,
         l_purch_flag, l_description
         from mtl_system_items_b_kfv
         where inventory_item_id = l_eam_mat_req_rec.inventory_item_id
         and organization_id = l_eam_mat_req_rec.organization_id;

      IF l_non_stock_flag = 'Y' then
         --fix for 3550864.allocate requested_quantity if passed
					   IF(l_eam_mat_req_rec.requested_quantity IS NOT NULL) THEN

							 EAM_MATERIAL_REQUEST_PVT.allocate
												 (p_api_version        => 1.0,
												 p_init_msg_list      => fnd_api.g_false,
												 p_commit             => fnd_api.g_false,
												 p_wip_entity_id      => l_eam_mat_req_rec.wip_entity_id,
												 p_organization_id    => l_eam_mat_req_rec.organization_id,
												 p_operation_seq_num  => l_eam_mat_req_rec.operation_seq_num,
												 p_inventory_item_id  => l_eam_mat_req_rec.inventory_item_id,
												 p_wip_entity_type    => wip_constants.discrete,
												 p_requested_quantity =>l_eam_mat_req_rec.requested_quantity,
												 p_source_subinventory => l_eam_mat_req_rec.supply_subinventory,
                                                                                                 p_source_locator      => l_eam_mat_req_rec.supply_locator_id,
												 x_request_number     => l_req_number,
												 x_return_status      => l_pick_return_status,
												 x_msg_data           => l_err_text,
												 x_msg_count          => l_msg_count);

					  ELSE


											   IF l_old_eam_wo_rec.status_type in (3,4) -- released, complete
											   and l_old_eam_wo_rec.material_issue_by_mo = 'Y'
											   and l_old_eam_wo_rec.maintenance_object_source = 1 -- Only for EAM
											   and l_eam_mat_req_rec.wip_supply_type =1   --only for 'push' type items..allocations shud not be done for bulk items
											   and
											   ((l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
												 and l_old_eam_mat_req_rec.auto_request_material = 'N'
												 and l_eam_mat_req_rec.auto_request_material = 'Y'  -- AUTO_REQUEST_MATERIAL flag turned on
												) OR
												(l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
												 and l_old_eam_mat_req_rec.required_quantity <> l_eam_mat_req_rec.required_quantity -- reqd qty updating
												) OR
												(l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
												 and l_eam_mat_req_rec.auto_request_material = 'Y' -- new mtl line adding with auto req flag on.
												)
											   )
											   THEN

														l_eam_mat_req_rec.invoke_allocations_api := 'Y';

											   END IF;
					 END IF;--end of check for requested_quantity
	      END IF;



       -- create requisitions if the quantity has changed and wo is in released status
       -- and item is non-stockable/purchasable item.
       select status_type into l_wo_status from
         wip_discrete_jobs
         where wip_entity_id = l_eam_mat_req_rec.wip_entity_id
         and organization_id = l_eam_mat_req_rec.organization_id;


--fix for 3550864.create requisitions for  requested_quantity if passed
       IF(l_non_stock_flag = 'N' and l_eam_mat_req_rec.requested_quantity IS NOT NULL) THEN



		select mic.category_id into l_purch_cat_id
		from mtl_item_categories mic,
		mtl_default_category_sets mdcs where
		mic.inventory_item_id = l_eam_mat_req_rec.inventory_item_id
		and mic.organization_id = l_eam_mat_req_rec.organization_id
		and mic.category_set_id = mdcs.category_set_id
		and mdcs.functional_area_id = 2;


                EAM_PROCESS_WO_UTIL_PVT.create_requisition
                  (  p_api_version                 => 1.0
                    ,p_init_msg_list               => FND_API.G_FALSE
                    ,p_commit                      => FND_API.G_FALSE
                    ,p_validate_only               => FND_API.G_TRUE
                    ,x_return_status               => l_api_return_status
                    ,x_msg_count                   => l_api_msg_count
                    ,x_msg_data                    => l_api_msg_data
                    ,p_wip_entity_id               => l_eam_mat_req_rec.wip_entity_id
                    ,p_operation_seq_num           => l_eam_mat_req_rec.operation_seq_num
                    ,p_organization_id             => l_eam_mat_req_rec.organization_id
                    ,p_user_id                     => fnd_global.user_id
                    ,p_responsibility_id           => fnd_global.resp_id
                    ,p_quantity                    => l_eam_mat_req_rec.requested_quantity
                    ,p_unit_price                  => l_eam_mat_req_rec.unit_price
                    ,p_category_id                 => l_purch_cat_id
                    ,p_item_description            => l_description
                    ,p_uom_code                    => l_uom_code
                    ,p_need_by_date                => l_eam_mat_req_rec.date_required
                    ,p_inventory_item_id           => l_eam_mat_req_rec.inventory_item_id
                    ,p_direct_item_id              => null
		    , p_suggested_vendor_id        => l_eam_mat_req_rec.vendor_id
                    ,p_suggested_vendor_name       => l_eam_mat_req_rec.suggested_vendor_name
                    ,p_suggested_vendor_site       => null
                    ,p_suggested_vendor_phone      => null
                    ,p_suggested_vendor_item_num   => null
                 );


   IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('create requisitions for non-stockable direct items'); END IF;

       ELSE


       if l_wo_status = 3
         and l_eam_mat_req_rec.auto_request_material = 'Y'
         and l_non_stock_flag = 'N'
         and l_purch_flag = 'Y'
         and (l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
              OR (l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                  /*and l_old_eam_mat_req_rec.required_quantity < l_eam_mat_req_rec.required_quantity commented for #6118897*/)
              OR (l_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                  and nvl(l_old_eam_mat_req_rec.auto_request_material,'N')='N')
       )then

		select mic.category_id into l_purch_cat_id
		from mtl_item_categories mic,
		mtl_default_category_sets mdcs where
		mic.inventory_item_id = l_eam_mat_req_rec.inventory_item_id
		and mic.organization_id = l_eam_mat_req_rec.organization_id
		and mic.category_set_id = mdcs.category_set_id
		and mdcs.functional_area_id = 2;


-- query modified for bug# 3691325.
-- query modified for bug# 4862404 (Performance).
/*union added for #6118897 to avoid duplicate requisition creation -- start*/

                l_req_for_cancel_qty_profile := FND_PROFILE.VALUE('EAM_TRIGGER_REQ_CANCEL_QTY');  --bug 13102446

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.MATERIAL_REQUIREMENTS : PROFILE : EAM: Trigger requisition for cancelled quantity : '||l_req_for_cancel_qty_profile); END IF;

                IF(NVL(l_req_for_cancel_qty_profile,'Y') = 'Y') then
                      -- trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN

                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/

                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id = l_eam_mat_req_rec.wip_entity_id
                        AND pria.destination_organization_id = l_eam_mat_req_rec.organization_id
                        AND pria.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        AND pria.item_id = l_eam_mat_req_rec.inventory_item_id
                        AND pria.wip_resource_seq_num is null
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
                        AND prla.wip_entity_id = l_eam_mat_req_rec.wip_entity_id
                        AND prla.destination_organization_id = l_eam_mat_req_rec.organization_id
                        AND prla.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        AND prla.item_id = l_eam_mat_req_rec.inventory_item_id
                        AND prla.wip_resource_seq_num is null

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND UPPER(NVL(pl.cancel_flag,'N')) <> 'Y'
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND pd.wip_entity_id = l_eam_mat_req_rec.wip_entity_id
                        AND pd.destination_organization_id = l_eam_mat_req_rec.organization_id
                        AND pd.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        AND pl.item_id = l_eam_mat_req_rec.inventory_item_id
                        AND pd.wip_resource_seq_num is null
                        AND pd.line_location_id not in(
                               SELECT nvl(prla.line_location_id,0)
                               FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                               WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                               AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                               AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
                               AND prla.wip_entity_id =l_eam_mat_req_rec.wip_entity_id
                               AND prla.destination_organization_id = l_eam_mat_req_rec.organization_id
                               AND prla.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                               AND prla.item_id = l_eam_mat_req_rec.inventory_item_id
                               AND prla.wip_resource_seq_num is null)
                        );

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_total_req_qty := 0 ;
                        END;

                ELSE  -- Don't trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN
                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/

                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id = l_eam_mat_req_rec.wip_entity_id
                        AND pria.destination_organization_id = l_eam_mat_req_rec.organization_id
                        AND pria.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        AND pria.item_id = l_eam_mat_req_rec.inventory_item_id
                        AND pria.wip_resource_seq_num is null
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND prla.wip_entity_id = l_eam_mat_req_rec.wip_entity_id
                        AND prla.destination_organization_id = l_eam_mat_req_rec.organization_id
                        AND prla.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        AND prla.item_id = l_eam_mat_req_rec.inventory_item_id
                        AND prla.wip_resource_seq_num is null

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND pd.wip_entity_id = l_eam_mat_req_rec.wip_entity_id
                        AND pd.destination_organization_id = l_eam_mat_req_rec.organization_id
                        AND pd.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        AND pl.item_id = l_eam_mat_req_rec.inventory_item_id
                        AND pd.wip_resource_seq_num is null
                        AND pd.line_location_id not in(
                        	SELECT nvl(prla.line_location_id,0)
                        	FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        	WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        	AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        	AND prla.wip_entity_id =l_eam_mat_req_rec.wip_entity_id
                        	AND prla.destination_organization_id = l_eam_mat_req_rec.organization_id
                        	AND prla.wip_operation_seq_num = l_eam_mat_req_rec.operation_seq_num
                        	AND prla.item_id = l_eam_mat_req_rec.inventory_item_id
                        	AND prla.wip_resource_seq_num is null)
                        );


                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                       l_total_req_qty := 0 ;
                       END;

                 END IF; --IF(NVL(l_req_for_cancel_qty_profile,'Y') = 'Y') then


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
EAM_ERROR_MESSAGE_PVT.Write_Debug('MATERIAL_REQUIREMENTS : Available Req/PO Qty: '||l_total_req_qty ||' Required Qty: '||l_eam_mat_req_rec.required_quantity||' Creating req for Qty: '||(l_eam_mat_req_rec.required_quantity-nvl(l_total_req_qty,0)) );
END IF;

             EAM_PROCESS_WO_UTIL_PVT.create_requisition
               (  p_api_version                 => 1.0
                 ,p_init_msg_list               => FND_API.G_FALSE
                 ,p_commit                      => FND_API.G_FALSE
                 ,p_validate_only               => FND_API.G_TRUE
                 ,x_return_status               => l_api_return_status
                 ,x_msg_count                   => l_api_msg_count
                 ,x_msg_data                    => l_api_msg_data
                 ,p_wip_entity_id               => l_eam_mat_req_rec.wip_entity_id
                 ,p_operation_seq_num           => l_eam_mat_req_rec.operation_seq_num
                 ,p_organization_id             => l_eam_mat_req_rec.organization_id
                 ,p_user_id                     => fnd_global.user_id
                 ,p_responsibility_id           => fnd_global.resp_id
                 ,p_quantity                    => (l_eam_mat_req_rec.required_quantity
                                                   -nvl(l_total_req_qty,0))
                 ,p_unit_price                  => l_eam_mat_req_rec.unit_price
                 ,p_category_id                 => l_purch_cat_id
                 ,p_item_description            => l_description
                 ,p_uom_code                    => l_uom_code
                 ,p_need_by_date                => l_eam_mat_req_rec.date_required
                 ,p_inventory_item_id           => l_eam_mat_req_rec.inventory_item_id
                 ,p_direct_item_id              => null
		 , p_suggested_vendor_id        => l_eam_mat_req_rec.vendor_id
                 ,p_suggested_vendor_name       => l_eam_mat_req_rec.suggested_vendor_name
                 ,p_suggested_vendor_site       => null
                 ,p_suggested_vendor_phone      => null
                 ,p_suggested_vendor_item_num   => null
              );

       end if;

     END IF;   --end of check for requested_quantity

    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS



    --  Load tables.
    l_eam_mat_req_tbl(I)          := l_eam_mat_req_rec;


    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
        l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;

         l_process_children             := FALSE;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;

         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;

         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;

         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_MAT_REQ_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   END LOOP; -- END Material Requirements processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.MATERIAL_REQUIREMENTS : End Return status: '||NVL(l_return_status, 'S')||' =======================') ; END IF ;

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
   x_return_status     := l_return_status;
   END IF;

   x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   x_eam_mat_req_tbl              := l_eam_mat_req_tbl;

END MATERIAL_REQUIREMENTS;


















PROCEDURE DIRECT_ITEMS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_department_id           IN  NUMBER := NULL
        ,  p_eam_direct_items_tbl         IN EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	,  x_material_shortage       IN OUT NOCOPY NUMBER
        ,  x_eam_direct_items_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_direct_items_rec       EAM_PROCESS_WO_PUB.eam_direct_items_rec_type ;
l_eam_direct_items_tbl       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type ;
l_old_eam_direct_items_rec   EAM_PROCESS_WO_PUB.eam_direct_items_rec_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_old_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type ;
l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type ;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;

l_out_eam_direct_items_rec   EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
l_out_eam_direct_items_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_pick_return_status    VARCHAR2(1) ;
l_msg_count             NUMBER := 0;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;
l_organization_id        NUMBER := p_organization_id ;
l_wip_entity_id           NUMBER := p_wip_entity_id ;
l_operation_seq_num    NUMBER := p_operation_seq_num ;
l_wo_status            NUMBER := 0;

l_api_return_status    VARCHAR2(1) := '';
l_api_msg_count        NUMBER;
l_api_msg_data         VARCHAR2(80);
l_total_req_qty		NUMBER;
l_req_for_cancel_qty_profile VARCHAR2(1);

BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.DIRECT_ITEMS : Start=== '||p_eam_direct_items_tbl.COUNT ||' records passed =======================') ; END IF ;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_direct_items_tbl    := p_eam_direct_items_tbl ;


	/* Get the materials in the Operation 1 and append to the table l_eam_direct_items_tbl */
   IF ( p_operation_seq_num IS NOT NULL
      and EAM_DIRECT_ITEMS_UTILITY_PVT.NUM_OF_ROW
       (  p_organization_id   => l_organization_id
        , p_wip_entity_id     => l_wip_entity_id
        , p_operation_seq_num => 1
       )  in  (TRUE)) THEN

       l_out_eam_direct_items_tbl := l_eam_direct_items_tbl ;
       EAM_DIRECT_ITEMS_DEFAULT_PVT.GetDI_In_Op1
	   (  p_eam_direct_items_tbl => l_eam_direct_items_tbl
	    , p_organization_id => l_organization_id
		, p_wip_entity_id => l_wip_entity_id
		, x_eam_direct_items_tbl => l_out_eam_direct_items_tbl
       );
	   l_eam_direct_items_tbl := l_out_eam_direct_items_tbl ;


  END IF;


   FOR I IN 1..l_eam_direct_items_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_direct_items_rec := l_eam_direct_items_tbl(I);

      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;


      IF l_eam_direct_items_rec.wip_entity_id is NULL
         AND (l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_direct_items_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL AND
         p_operation_seq_num IS NOT NULL AND
         p_department_id IS NOT NULL
      THEN
         l_parent_exists := TRUE;
         l_eam_direct_items_rec.department_id := p_department_id;
      END IF;

      IF(l_eam_direct_items_rec.suggested_vendor_name  is not null and l_eam_direct_items_rec.suggested_vendor_id is null) THEN
      BEGIN
        SELECT vendor_id INTO l_eam_direct_items_rec.suggested_vendor_id
        FROM   po_suppliers_val_v
        WHERE upper(vendor_name) = upper(l_eam_direct_items_rec.suggested_vendor_name );
      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;
      END IF;


      -- Check if record has not yet been processed and that it is the child of the parent that called this procedure

      IF (l_eam_direct_items_rec.return_status IS NULL OR l_eam_direct_items_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_direct_items_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_direct_items_rec.organization_id = p_organization_id AND
              (l_eam_direct_items_rec.operation_seq_num = p_operation_seq_num OR
               l_eam_direct_items_rec.operation_seq_num = 1
              )
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_direct_items_rec.return_status := FND_API.G_RET_STS_SUCCESS;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating Transaction Type') ; END IF ;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_direct_items_rec.transaction_type
        ,   p_entity_name       => 'DIRECT_ITEMS'
        ,   p_entity_id         => to_char(l_eam_direct_items_rec.direct_item_sequence_id)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking Existence of Record') ; END IF ;

         EAM_DIRECT_ITEMS_VALIDATE_PVT.Check_Existence
         (  p_eam_direct_items_rec            => l_eam_direct_items_rec
         ,  x_old_eam_direct_items_rec        => l_old_eam_direct_items_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_DI_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'DI_SEQ_ID';
            l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_direct_items_rec.wip_entity_id;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_DI_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'DI_SEQ_ID';
            l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_direct_items_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_direct_items_rec.transaction_type := l_old_eam_direct_items_rec.transaction_type;
        END IF;


        IF l_eam_direct_items_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

	IF l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE THEN
		x_material_shortage := G_MATERIAL_UPDATE;
	END IF;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;

           l_out_eam_direct_items_rec := l_eam_direct_items_rec;

           EAM_DIRECT_ITEMS_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_direct_items_rec        => l_eam_direct_items_rec
           ,   p_old_eam_direct_items_Rec    => l_old_eam_direct_items_rec
           ,   x_eam_direct_items_rec     => l_out_eam_direct_items_rec
           ) ;

           l_eam_direct_items_rec := l_out_eam_direct_items_rec;


		    IF ( p_operation_seq_num IS NOT NULL
	              and l_eam_direct_items_rec.operation_seq_num = 1 ) THEN

                 l_out_eam_direct_items_rec := l_eam_direct_items_rec;

                 EAM_DIRECT_ITEMS_DEFAULT_PVT.Change_OpSeqNum1
                 (    p_eam_direct_items_rec    => l_eam_direct_items_rec
                    , p_operation_seq_num  =>  p_operation_seq_num
                    , p_department_id => p_department_id
                    , x_eam_direct_items_rec =>  l_out_eam_direct_items_rec
                 ) ;

                 l_eam_direct_items_rec := l_out_eam_direct_items_rec;
            END IF;

        ELSIF l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN

  	   x_material_shortage := G_MATERIAL_UPDATE;
           l_out_eam_direct_items_rec := l_eam_direct_items_rec;

           EAM_DIRECT_ITEMS_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_direct_items_rec   => l_eam_direct_items_rec
           ,   x_eam_direct_items_rec   => l_out_eam_direct_items_rec
           ,   x_mesg_token_tbl    => l_mesg_token_tbl
           ,   x_return_status     => l_return_status
           ) ;

           l_eam_direct_items_rec := l_out_eam_direct_items_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_DI_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name  := 'DI_SEQ_ID';
              l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_DI_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'DI_SEQ_ID';
              l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
               );
              l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;
          END IF;
       END IF;


         EAM_DIRECT_ITEMS_VALIDATE_PVT.Check_Required
         ( p_eam_direct_items_rec                => l_eam_direct_items_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_DI_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'DI_SEQ_ID';
               l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_DI_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'DI_SEQ_ID';
            l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_DIRECT_ITEMS_VALIDATE_PVT.Check_Attributes
            ( p_eam_direct_items_rec        => l_eam_direct_items_rec
            , p_old_eam_direct_items_rec    => l_old_eam_direct_items_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

	IF l_old_eam_direct_items_rec.REQUIRED_QUANTITY <> l_eam_direct_items_rec.REQUIRED_QUANTITY THEN
		x_material_shortage := G_MATERIAL_UPDATE;
	END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_DI_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'DI_SEQ_ID';
                  l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_DI_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'DI_SEQ_ID';
               l_other_token_tbl(1).token_value := l_eam_direct_items_rec.direct_item_sequence_id ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               ( p_eam_direct_items_tbl        => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
               );
              l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

           END IF;



          EAM_DIRECT_ITEMS_UTILITY_PVT.Perform_Writes
          (   p_eam_direct_items_rec          => l_eam_direct_items_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_DI_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'DI_SEQ_ID';
          l_other_token_tbl(1).token_value :=
                          l_eam_direct_items_rec.direct_item_sequence_id ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               ( p_eam_direct_items_tbl        => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
               );
              l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;
       END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Direct Items Database writes completed with status  ' || l_return_status); END IF;

--fix for 3550864.create requisitions for  requested_quantity if passed
     IF(l_eam_direct_items_rec.requested_quantity IS NOT NULL) THEN

   IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('create requisitions for description direct items'); END IF;

       EAM_PROCESS_WO_UTIL_PVT.create_requisition
                  (  p_api_version                 => 1.0
                    ,p_init_msg_list               => FND_API.G_FALSE
                    ,p_commit                      => FND_API.G_FALSE
                    ,p_validate_only               => FND_API.G_TRUE
                    ,x_return_status               => l_api_return_status
                    ,x_msg_count                   => l_api_msg_count
                    ,x_msg_data                    => l_api_msg_data
                    ,p_wip_entity_id               => l_eam_direct_items_rec.wip_entity_id
                    ,p_operation_seq_num           => l_eam_direct_items_rec.operation_seq_num
                    ,p_organization_id             => l_eam_direct_items_rec.organization_id
                    ,p_user_id                     => fnd_global.user_id
                    ,p_responsibility_id           => fnd_global.resp_id
                    ,p_quantity                    => l_eam_direct_items_rec.requested_quantity
                    ,p_unit_price                  => l_eam_direct_items_rec.unit_price
                    ,p_category_id                 => l_eam_direct_items_rec.purchasing_category_id
                    ,p_item_description            => l_eam_direct_items_rec.description
                    ,p_uom_code                    => l_eam_direct_items_rec.uom
                    ,p_need_by_date                => l_eam_direct_items_rec.need_by_date
                    ,p_inventory_item_id           => null
                    ,p_direct_item_id              => l_eam_direct_items_rec.direct_item_sequence_id
		    , p_suggested_vendor_id        => l_eam_direct_items_rec.suggested_vendor_id
                    ,p_suggested_vendor_name       => l_eam_direct_items_rec.suggested_vendor_name
                    ,p_suggested_vendor_site       => l_eam_direct_items_rec.suggested_vendor_site
                    ,p_suggested_vendor_phone      => l_eam_direct_items_rec.suggested_vendor_phone
                    ,p_suggested_vendor_item_num   => l_eam_direct_items_rec.suggested_vendor_item_num);

     ELSE

       -- create requisitions if the quantity has changed and wo is in released status
       select status_type into l_wo_status from
         wip_discrete_jobs
         where wip_entity_id = l_eam_direct_items_rec.wip_entity_id
         and organization_id = l_eam_direct_items_rec.organization_id;
       if l_wo_status = 3
         and l_eam_direct_items_rec.auto_request_material = 'Y'
         and (l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
              OR (l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                  /*and l_old_eam_direct_items_rec.required_quantity < l_eam_direct_items_rec.required_quantity commented for # 6118897*/)
              OR (l_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                  and nvl(l_old_eam_direct_items_rec.auto_request_material,'N')='N'
                  and nvl(l_eam_direct_items_rec.auto_request_material,'N')='Y')
       ) then

-- query modified for bug# 3691325.

     /*Added Union for #6118897 to avoid duplicate req creation -- start --*/

             l_req_for_cancel_qty_profile := FND_PROFILE.VALUE('EAM_TRIGGER_REQ_CANCEL_QTY');  --bug 13102446

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.DIRECT_ITEMS , PROFILE : EAM: Trigger requisition for cancelled quantity : '||l_req_for_cancel_qty_profile); END IF;

             IF(NVL(l_req_for_cancel_qty_profile,'Y') = 'Y') then
                   --13102446 trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN

                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/

                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id =l_eam_direct_items_rec.wip_entity_id
                        AND pria.destination_organization_id = l_eam_direct_items_rec.organization_id
                        AND pria.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                        AND pria.item_id is null
                        AND pria.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
                        AND prla.wip_entity_id =l_eam_direct_items_rec.wip_entity_id
                        AND prla.destination_organization_id = l_eam_direct_items_rec.organization_id
                        AND prla.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                        AND prla.item_id is null
                        AND prla.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND UPPER(NVL(pl.cancel_flag,'N')) <> 'Y'
                        AND pd.wip_entity_id = l_eam_direct_items_rec.wip_entity_id
                        AND pd.destination_organization_id = l_eam_direct_items_rec.organization_id
                        AND pd.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                        AND pl.item_id is null
                        AND pd.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id
                        AND pd.line_location_id not in(
	                        SELECT nvl(prla.line_location_id,0)
	                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
	                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
	                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED')
	                        AND UPPER(NVL(prla.cancel_flag,'N')) <> 'Y'
	                        AND prla.wip_entity_id =l_eam_direct_items_rec.wip_entity_id
	                        AND prla.destination_organization_id = l_eam_direct_items_rec.organization_id
	                        AND prla.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
	                        AND prla.item_id is null
	                        AND prla.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id)
                        );
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_total_req_qty := 0;
                        END;

             ELSE  -- Don't trigger requisition again for the cancelled quantity where the earlier Req/PO was cancelled

                        BEGIN
                        /*Querying table po_requisitions_interface_all also to avoid duplication of requisitions, added for bug #6112450*/
                        SELECT SUM(nvl(req_qty,0)) INTO l_total_req_qty
                        FROM
                        (SELECT SUM(nvl(pria.quantity,0)) req_qty
                        FROM po_requisitions_interface_all pria
                        WHERE  pria.wip_entity_id =l_eam_direct_items_rec.wip_entity_id
                        AND pria.destination_organization_id = l_eam_direct_items_rec.organization_id
                        AND pria.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                        AND pria.item_id is null
                        AND pria.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id
                        AND ((process_flag is null) or (Upper(Trim(process_flag)) = 'IN PROCESS'))

                        UNION ALL
                        SELECT SUM(nvl(prla.quantity,0)) req_qty
                        FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                        WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                        AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND prla.wip_entity_id =l_eam_direct_items_rec.wip_entity_id
                        AND prla.destination_organization_id = l_eam_direct_items_rec.organization_id
                        AND prla.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                        AND prla.item_id is null
                        AND prla.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id

                        UNION ALL
                        SELECT SUM(nvl(pd.quantity_ordered,0)) req_qty
                        FROM po_distributions_all pd , po_headers_all ph,po_lines_all pl
                        WHERE pd.po_header_id = ph.po_header_id(+)
                        AND upper(NVL(ph.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                        AND pd.po_line_id = pl.po_line_id(+)
                        AND pd.wip_entity_id = l_eam_direct_items_rec.wip_entity_id
                        AND pd.destination_organization_id = l_eam_direct_items_rec.organization_id
                        AND pd.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                        AND pl.item_id is null
                        AND pd.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id
                        AND pd.line_location_id not in(
                               SELECT nvl(prla.line_location_id,0)
                               FROM po_requisition_lines_all prla , po_requisition_headers_all prha
                               WHERE prla.requisition_header_id = prha.requisition_header_id(+)
                               AND upper(NVL(prha.authorization_status, 'APPROVED') ) not in ('SYSTEM_SAVED')
                               AND prla.wip_entity_id =l_eam_direct_items_rec.wip_entity_id
                               AND prla.destination_organization_id = l_eam_direct_items_rec.organization_id
                               AND prla.wip_operation_seq_num = l_eam_direct_items_rec.operation_seq_num
                               AND prla.item_id is null
                               AND prla.wip_resource_seq_num = l_eam_direct_items_rec.direct_item_sequence_id)
                        );
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_total_req_qty := 0;
                        END;

             END IF;  --IF(l_req_for_cancel_qty_profile = 'Y') then

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
EAM_ERROR_MESSAGE_PVT.Write_Debug('DIRECT_ITEMS : Available Req/PO Qty:'||l_total_req_qty ||' Required Qty: '||l_eam_direct_items_rec.required_quantity||' Creating req for Qty: '||(l_eam_direct_items_rec.required_quantity-nvl(l_total_req_qty,0)) );
END IF;

             EAM_PROCESS_WO_UTIL_PVT.create_requisition
               (  p_api_version                 => 1.0
                 ,p_init_msg_list               => FND_API.G_FALSE
                 ,p_commit                      => FND_API.G_FALSE
                 ,p_validate_only               => FND_API.G_TRUE
                 ,x_return_status               => l_api_return_status
                 ,x_msg_count                   => l_api_msg_count
                 ,x_msg_data                    => l_api_msg_data
                 ,p_wip_entity_id               => l_eam_direct_items_rec.wip_entity_id
                 ,p_operation_seq_num           => l_eam_direct_items_rec.operation_seq_num
                 ,p_organization_id             => l_eam_direct_items_rec.organization_id
                 ,p_user_id                     => fnd_global.user_id
                 ,p_responsibility_id           => fnd_global.resp_id
                 ,p_quantity                    => (l_eam_direct_items_rec.required_quantity
                                                   -nvl(l_total_req_qty,0))
                 ,p_unit_price                  => l_eam_direct_items_rec.unit_price
                 ,p_category_id                 => l_eam_direct_items_rec.purchasing_category_id
                 ,p_item_description            => l_eam_direct_items_rec.description
                 ,p_uom_code                    => l_eam_direct_items_rec.uom
                 ,p_need_by_date                => l_eam_direct_items_rec.need_by_date
                 ,p_inventory_item_id           => null
                 ,p_direct_item_id              => l_eam_direct_items_rec.direct_item_sequence_id
		 , p_suggested_vendor_id        => l_eam_direct_items_rec.suggested_vendor_id
                 ,p_suggested_vendor_name       => l_eam_direct_items_rec.suggested_vendor_name
                 ,p_suggested_vendor_site       => l_eam_direct_items_rec.suggested_vendor_site
                 ,p_suggested_vendor_phone      => l_eam_direct_items_rec.suggested_vendor_phone
                 ,p_suggested_vendor_item_num   => l_eam_direct_items_rec.suggested_vendor_item_num);

       end if;
    END IF;  --end of check for requested_quantity

    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_eam_direct_items_tbl(I)          := l_eam_direct_items_rec;


    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
        l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

         l_process_children             := FALSE;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
       l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
       l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
       l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
       l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
       l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_DIRECT_ITEMS_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl        => l_out_eam_direct_items_tbl
        );
       l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   END LOOP; -- END Material Requirements processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.DIRECT_ITEMS : End Return status: '||NVL(l_return_status, 'S')||' ===========================') ; END IF ;
   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
   x_return_status     := l_return_status;
   END IF;

   x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
   x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

END DIRECT_ITEMS;




















PROCEDURE OPERATION_RESOURCES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled       IN OUT NOCOPY NUMBER
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_res_rec            EAM_PROCESS_WO_PUB.eam_res_rec_type ;
l_eam_res_tbl            EAM_PROCESS_WO_PUB.eam_res_tbl_type ;
l_old_eam_res_rec        EAM_PROCESS_WO_PUB.eam_res_rec_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type   :=p_eam_res_inst_tbl;
l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type := p_eam_res_usage_tbl;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type ;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type ;

        -- baroy - added for making the NOCOPY changes
        l_out_eam_res_rec                EAM_PROCESS_WO_PUB.eam_res_rec_type;
        l_out_eam_res_tbl                EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl           EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_res_usage_tbl          EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;


BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.OPERATION_RESOURCES : Start=== '||p_eam_res_tbl.COUNT ||' records passed =======================') ; END IF ;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_res_tbl    := p_eam_res_tbl ;


   FOR I IN 1..l_eam_res_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_res_rec := l_eam_res_tbl(I);

      -- make sure to set process_children to false at the start of every iteration
      l_process_children := FALSE;


      IF l_eam_res_rec.wip_entity_id is NULL
         AND (l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_res_rec.wip_entity_id := p_wip_entity_id;
      END IF;

      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL AND
         p_operation_seq_num IS NOT NULL
      THEN
	l_parent_exists := TRUE;
      END IF;

      IF (l_eam_res_rec.return_status IS NULL OR l_eam_res_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_res_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_res_rec.organization_id = p_organization_id AND
              l_eam_res_rec.operation_seq_num = p_operation_seq_num
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_res_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_res_rec.transaction_type
        ,   p_entity_name       => 'OPERATION_RESOURCE'
        ,   p_entity_id         => to_char(l_eam_res_rec.resource_seq_num)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

        EAM_RES_VALIDATE_PVT.Check_Existence
         (  p_eam_res_rec            => l_eam_res_rec
         ,  x_old_eam_res_rec        => l_old_eam_res_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_RES_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_res_rec.wip_entity_id;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_RES_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_res_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_res_rec.transaction_type := l_old_eam_res_rec.transaction_type;
        END IF;


        IF l_eam_res_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;

           l_out_eam_res_rec           := l_eam_res_rec;
           EAM_RES_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_res_rec        => l_eam_res_rec
           ,   p_old_eam_res_Rec    => l_old_eam_res_rec
           ,   x_eam_res_rec     => l_out_eam_res_rec
           ) ;
           l_eam_res_rec           := l_out_eam_res_rec;

        END IF;


           l_out_eam_res_rec           := l_eam_res_rec;
           EAM_RES_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_res_rec   => l_eam_res_rec
           ,   x_eam_res_rec   => l_out_eam_res_rec
           ,   x_mesg_token_tbl  => l_mesg_token_tbl
           ,   x_return_status   => l_return_status
           ) ;
           l_eam_res_rec           := l_out_eam_res_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_RES_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                          l_eam_res_rec.resource_seq_num ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_RES_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
              l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
              l_out_eam_res_tbl           := l_eam_res_tbl;
              l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
              l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_res_tbl           := l_out_eam_res_tbl;
              l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
              l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
          END IF;


         EAM_RES_VALIDATE_PVT.Check_Required
         ( p_eam_res_rec                => l_eam_res_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_RES_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_RES_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'RES_SEQ_NUMBER';
            l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;

            EAM_RES_VALIDATE_PVT.Check_Attributes
            ( p_eam_res_rec        => l_eam_res_rec
            , p_old_eam_res_rec    => l_old_eam_res_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_RES_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_RES_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
               l_other_token_tbl(1).token_value := l_eam_res_rec.resource_seq_num ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
              l_out_eam_res_tbl           := l_eam_res_tbl;
              l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
              l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
              l_eam_res_tbl           := l_out_eam_res_tbl;
              l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
              l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;

           END IF;

          EAM_RES_UTILITY_PVT.Perform_Writes
          (   p_eam_res_rec         => l_eam_res_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_RES_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'RES_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                          l_eam_res_rec.resource_seq_num ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_res_tbl           := l_eam_res_tbl;
            l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
               );
            l_eam_res_tbl           := l_out_eam_res_tbl;
            l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
            l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;

       END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Resources Database writes completed with status  ' || l_return_status); END IF;

     --find if scheduler is to be called or not
         IF(x_schedule_wo = G_NOT_SCHEDULE_WO)THEN    --not yet set to schedule
	     IF(l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE   -- is resource is added
	        OR (l_eam_res_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_DELETE AND l_eam_res_rec.scheduled_flag=1) --deleted and was scheduled
		OR (l_eam_res_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND  --updating the resource
		       (NVL(l_eam_res_rec.schedule_seq_num,l_eam_res_rec.resource_seq_num)<>NVL(l_old_eam_res_rec.schedule_seq_num,l_old_eam_res_rec.resource_seq_num)
		        OR l_eam_res_rec.start_date <> l_old_eam_res_rec.start_date   --shedule_seq_num,start_date,completion_date
			OR l_eam_res_rec.completion_date <> l_old_eam_res_rec.completion_date
			OR l_eam_res_rec.resource_id <> l_old_eam_res_rec.resource_id    --resource_code,usage_rate_or_amount,scheduled_flag,assigned_units
			OR l_eam_res_rec.usage_rate_or_amount <> l_old_eam_res_rec.usage_rate_or_amount
			OR l_eam_res_rec.scheduled_flag <> l_old_eam_res_rec.scheduled_flag
			OR NVL(l_eam_res_rec.assigned_units,0) <> NVL(l_old_eam_res_rec.assigned_units,0))
		    )
		) THEN
		    x_schedule_wo := G_SCHEDULE_WO;
	     END IF;
	 END IF;

     --find if bottom up scheduler is to be called or not


	-- IF(x_bottomup_scheduled = G_NOT_BU_SCHEDULE_WO)THEN    --not yet set to schedule
	     IF(l_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE   -- is resource is added
	    --    OR (l_eam_res_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_DELETE AND l_eam_res_rec.scheduled_flag=1) --deleted and was scheduled
		OR (l_eam_res_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND  --updating the resource
		       (
		       --NVL(l_eam_res_rec.schedule_seq_num,l_eam_res_rec.resource_seq_num)<>NVL(l_old_eam_res_rec.schedule_seq_num,l_old_eam_res_rec.resource_seq_num)
		        -- OR
			l_eam_res_rec.start_date <> l_old_eam_res_rec.start_date   --shedule_seq_num,start_date,completion_date
			OR l_eam_res_rec.completion_date <> l_old_eam_res_rec.completion_date
		--	OR l_eam_res_rec.resource_id <> l_old_eam_res_rec.resource_id    --resource_code,usage_rate_or_amount,scheduled_flag,assigned_units
		--	OR l_eam_res_rec.usage_rate_or_amount <> l_old_eam_res_rec.usage_rate_or_amount
		--	OR l_eam_res_rec.scheduled_flag <> l_old_eam_res_rec.scheduled_flag
		--	OR NVL(l_eam_res_rec.assigned_units,0) <> NVL(l_old_eam_res_rec.assigned_units,0)
			)
		    )
		) THEN
		    x_bottomup_scheduled := G_UPDATE_RES_USAGE;
	     END IF;
	-- END IF;

  -- Indicate that children need to be processed
    l_process_children := TRUE;

       IF l_process_children
       THEN

							      -- Process Resource Instance that are direct children of this operation
							IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling RESOURCE_INSTANCES from OPERATION_RESOURCES') ; END IF ;

								l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
								RESOURCE_INSTANCES
								(  p_validation_level              =>  p_validation_level
								,  p_wip_entity_id                 =>  l_eam_res_rec.wip_entity_id
								,  p_organization_id               =>  l_eam_res_rec.organization_id
								,  p_operation_seq_num             =>  l_eam_res_rec.operation_seq_num
								,  p_resource_seq_num              =>  l_eam_res_rec.resource_seq_num
								,  p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
								,  x_eam_res_inst_tbl              =>  l_out_eam_res_inst_tbl
								,  x_mesg_token_tbl                =>  l_mesg_token_tbl
								,  x_return_status                 =>  l_return_status
								,  x_schedule_wo		   =>  x_schedule_wo
								,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
								);
								l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;

							   IF l_return_status in ('Q', 'U')
							   THEN
							      x_return_status := l_return_status;
							      RETURN ;
							   ELSIF NVL(l_return_status, 'S') <> 'S'
							   THEN
							      x_return_status     := l_return_status;
							   END IF;



							      -- Process Resource Usage that are direct children of this operation
							IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling RESOURCE_USAGES from OPERATION_RESOURCES') ; END IF ;


								l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
								RESOURCE_USAGES
								(  p_validation_level              =>  p_validation_level
								,  p_wip_entity_id                 =>  l_eam_res_rec.wip_entity_id
								,  p_organization_id               =>  l_eam_res_rec.organization_id
								,  p_operation_seq_num             =>  l_eam_res_rec.operation_seq_num
								,  p_resource_seq_num             =>  l_eam_res_rec.resource_seq_num
								,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
								,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
								,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
								,  x_mesg_token_tbl                =>  l_mesg_token_tbl
								,  x_return_status                 =>  l_return_status
								);
								l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;


							   IF l_return_status in ('Q', 'U')
							   THEN
							      x_return_status := l_return_status;
							      RETURN ;
							   ELSIF NVL(l_return_status, 'S') <> 'S'
							   THEN
							      x_return_status     := l_return_status;
							   END IF;


   END IF;   -- Process children



    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_eam_res_tbl(I)          := l_eam_res_rec;



    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;

         l_process_children             := FALSE;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
       l_out_eam_res_tbl           := l_eam_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;

      WHEN EXC_SEV_SKIP_BRANCH THEN
       l_out_eam_res_tbl           := l_eam_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
       l_out_eam_res_tbl           := l_eam_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
       l_out_eam_res_tbl           := l_eam_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;



         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;



      WHEN EXC_FAT_QUIT_SIBLINGS THEN
       l_out_eam_res_tbl           := l_eam_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;



      WHEN EXC_UNEXP_SKIP_OBJECT THEN
       l_out_eam_res_tbl           := l_eam_res_tbl;
       l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
       l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_RES_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_eam_direct_items_tbl
        );
       l_eam_res_tbl           := l_out_eam_res_tbl;
       l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
       l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;



   END LOOP; -- END Resources processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.OPERATION_RESOURCES : End Return status: '||NVL(l_return_status, 'S')||' ===================') ; END IF ;


   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;


        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
	x_eam_res_usage_tbl	       := l_eam_res_usage_tbl;

END OPERATION_RESOURCES;












PROCEDURE WO_OPERATIONS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER
        ,  p_eam_op_tbl              IN EAM_PROCESS_WO_PUB.eam_op_tbl_type
        ,  p_eam_op_network_tbl      IN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        ,  p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        ,  p_eam_direct_items_tbl         IN EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        ,  x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
        ,  x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        ,  x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        ,  x_eam_direct_items_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
	,  x_material_shortage       IN OUT NOCOPY NUMBER
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        )
IS

l_eam_op_rec            EAM_PROCESS_WO_PUB.eam_op_rec_type ;
l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
l_old_eam_op_rec        EAM_PROCESS_WO_PUB.eam_op_rec_type ;

l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type ;
l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type :=p_eam_op_network_tbl;
l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type        :=p_eam_res_tbl;
l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type   :=p_eam_res_inst_tbl;
l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type    :=p_eam_sub_res_tbl;
l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type  :=p_eam_res_usage_tbl;
l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type    :=p_eam_mat_req_tbl;
l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type    :=p_eam_direct_items_tbl;


        -- baroy - added for making the NOCOPY changes
        l_out_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_rec                 EAM_PROCESS_WO_PUB.eam_op_rec_type;
        l_out_eam_op_tbl                 EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl         EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl                EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl           EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl            EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl          EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl            EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_direct_items_tbl            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

/* Error Handling Variables */
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
l_other_message         VARCHAR2(2000);
l_err_text              VARCHAR2(2000);
l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;

/* Others */
l_return_status         VARCHAR2(1) ;
l_bo_return_status      VARCHAR2(1) ;
l_parent_exists         BOOLEAN := FALSE ;
l_process_children      BOOLEAN := TRUE ;
l_valid_transaction     BOOLEAN := TRUE ;

l_source_code           VARCHAR2(10); -- CMRO bug 12757636


BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.WO_OPERATIONS : Start=== '||p_eam_op_tbl.COUNT ||' records passed =======================') ; END IF ;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --  Init local table variables.
   l_return_status    := 'S' ;
   l_bo_return_status := 'S' ;
   l_eam_op_tbl    := p_eam_op_tbl ;


   FOR I IN 1..l_eam_op_tbl.COUNT LOOP
   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

      --  Load local records.
      l_eam_op_rec := l_eam_op_tbl(I);


      -- make sure to set process_children to false at the start of every iteration

      l_process_children := FALSE;


      IF l_eam_op_rec.wip_entity_id is NULL
         AND (l_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
             OR l_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC)
      THEN
          l_eam_op_rec.wip_entity_id := p_wip_entity_id;
      END IF;


      IF p_wip_entity_id IS NOT NULL AND
         p_organization_id IS NOT NULL
      THEN
         l_parent_exists := TRUE;
      END IF;

      IF (l_eam_op_rec.return_status IS NULL OR l_eam_op_rec.return_status = FND_API.G_MISS_CHAR)
           AND
           (NOT l_parent_exists
            OR
             (l_parent_exists AND
              l_eam_op_rec.wip_entity_id = p_wip_entity_id AND
              l_eam_op_rec.organization_id = p_organization_id
             )
           )
      THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_eam_op_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_op_rec.transaction_type
        ,   p_entity_name       => 'OPERATION'
        ,   p_entity_id         => to_char(l_eam_op_rec.operation_seq_num)
        ,   X_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_mesg_token_tbl
        );

         IF NOT l_valid_transaction
         THEN
             l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
             RAISE EXC_SEV_QUIT_RECORD ;
         END IF ;

         EAM_OP_VALIDATE_PVT.Check_Existence
         (  p_eam_op_rec             => l_eam_op_rec
         ,  x_old_eam_op_rec         => l_old_eam_op_rec
         ,  x_mesg_token_tbl         => l_mesg_token_tbl
         ,  x_return_status          => l_return_status
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Existence completed with return_status: ' || l_return_status) ;  END IF ;

         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            l_other_message := 'EAM_OP_EXS_SEV_SKIP';
            l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value := l_eam_op_rec.operation_seq_num;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_op_rec.wip_entity_id;
            RAISE EXC_SEV_QUIT_BRANCH;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_OP_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value := l_eam_op_rec.operation_seq_num ;
            l_other_token_tbl(2).token_name  := 'WIP_ENTITY_ID';
            l_other_token_tbl(2).token_value := l_eam_op_rec.wip_entity_id ;
            RAISE EXC_UNEXP_SKIP_OBJECT;
         END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_op_rec.transaction_type := l_old_eam_op_rec.transaction_type;
        END IF;

        IF l_eam_op_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Populate NULL columns') ;
           END IF ;

           l_out_eam_op_rec := l_eam_op_rec;
           EAM_OP_DEFAULT_PVT.Populate_Null_Columns
           (   p_eam_op_rec        => l_eam_op_rec
           ,   p_old_eam_op_Rec    => l_old_eam_op_rec
           ,   x_eam_op_rec     => l_out_eam_op_rec
           ) ;
           l_eam_op_rec := l_out_eam_op_rec;


        ELSIF l_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN

           l_out_eam_op_rec := l_eam_op_rec;
           EAM_OP_DEFAULT_PVT.Attribute_Defaulting
           (   p_eam_op_rec   => l_eam_op_rec
           ,   x_eam_op_rec   => l_out_eam_op_rec
           ,   x_mesg_token_tbl  => l_mesg_token_tbl
           ,   x_return_status   => l_return_status
           ) ;
           l_eam_op_rec := l_out_eam_op_rec;

           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug
           ('Attribute Defaulting completed with return_status: ' || l_return_status) ;
           END IF ;


           IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
           THEN
              l_other_message := 'EAM_OP_ATTDEF_CSEV_SKIP';
              l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                          l_eam_op_rec.OPERATION_SEQ_NUM ;
              RAISE EXC_SEV_SKIP_BRANCH ;

           ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
           THEN
              l_other_message := 'EAM_OP_ATTDEF_UNEXP_SKIP';
              l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
              l_other_token_tbl(1).token_value :=
                           l_eam_op_rec.OPERATION_SEQ_NUM ;
              RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
           THEN
             l_out_eam_op_tbl            := l_eam_op_tbl;
             l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
             l_out_eam_res_tbl           := l_eam_res_tbl;
             l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
             l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
             l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
             l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_op_tbl             => l_eam_op_tbl
               ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_out_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
               );
             l_eam_op_tbl                := l_out_eam_op_tbl;
             l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
             l_eam_res_tbl               := l_out_eam_res_tbl;
             l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
             l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
             l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
             l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
          END IF;
       END IF;


         EAM_OP_VALIDATE_PVT.Check_Required
         ( p_eam_op_rec                 => l_eam_op_rec
         , x_return_status              => l_return_status
         , x_mesg_token_tbl             => l_mesg_token_tbl
         ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check required completed with return_status: ' || l_return_status) ; END IF ;


         IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
         THEN
            IF l_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
               l_other_message := 'EAM_OP_REQ_CSEV_SKIP';
               l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value := l_eam_op_rec.OPERATION_SEQ_NUM ;
               RAISE EXC_SEV_SKIP_BRANCH ;
            ELSE
               RAISE EXC_SEV_QUIT_RECORD ;
            END IF;
         ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
         THEN
            l_other_message := 'EAM_OP_REQ_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
            l_other_token_tbl(1).token_value := l_eam_op_rec.OPERATION_SEQ_NUM ;
            RAISE EXC_UNEXP_SKIP_OBJECT ;
         END IF;


            EAM_OP_VALIDATE_PVT.Check_Attributes
            ( p_eam_op_rec        => l_eam_op_rec
            , p_old_eam_op_rec    => l_old_eam_op_rec
            , x_return_status     => l_return_status
            , x_mesg_token_tbl    => l_mesg_token_tbl
            ) ;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute validation completed with return_status: ' || l_return_status) ; END IF ;

            IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
            THEN
               IF l_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
               THEN
                  l_other_message := 'EAM_OP_ATTVAL_CSEV_SKIP';
                  l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
                  l_other_token_tbl(1).token_value :=
                           l_eam_op_rec.OPERATION_SEQ_NUM ;
                  RAISE EXC_SEV_SKIP_BRANCH ;
                  ELSE
                     RAISE EXC_SEV_QUIT_RECORD ;
               END IF;
            ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
            THEN
               l_other_message := 'EAM_OP_ATTVAL_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                           l_eam_op_rec.OPERATION_SEQ_NUM ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
            ELSIF l_return_status ='S' AND l_mesg_token_tbl .COUNT <> 0
            THEN
             l_out_eam_op_tbl            := l_eam_op_tbl;
             l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
             l_out_eam_res_tbl           := l_eam_res_tbl;
             l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
             l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
             l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
             l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
              EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_op_tbl             => l_eam_op_tbl
               ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_out_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
               );
             l_eam_op_tbl                := l_out_eam_op_tbl;
             l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
             l_eam_res_tbl               := l_out_eam_res_tbl;
             l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
             l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
             l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
             l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;

           END IF;

          IF(x_schedule_wo = G_NOT_SCHEDULE_WO) THEN   --not firm and not yet set to schedule
	    IF (l_eam_op_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND
                         (l_eam_op_rec.start_date<>l_old_eam_op_rec.start_date
                           OR l_eam_op_rec.completion_date<>l_old_eam_op_rec.completion_date)) THEN
                       /*bug 12757636 - for CMRO*/
                       BEGIN
                       select source_code into l_source_code
                       from wip_discrete_jobs where wip_entity_id=l_eam_op_rec.wip_entity_id;
                       EXCEPTION
                       WHEN OTHERS THEN
                          l_source_code:='X';
                       END;
                       if(nvl(l_source_code, 'X')NOT IN ('MSC' , 'AHL'))then -- CMRO bug 12757636 , USAF bug 13493098
     		             l_eam_op_rec.start_date := l_old_eam_op_rec.start_date;      --set op dates to prev. dates
			     l_eam_op_rec.completion_date := l_old_eam_op_rec.completion_date;
                       end if;
	    END IF;
	  END IF;

          IF(x_bottomup_scheduled = G_NOT_BU_SCHEDULE_WO) THEN   --not firm and not yet set to schedule for bottom up
	    IF (l_eam_op_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND
                         (l_eam_op_rec.start_date<>l_old_eam_op_rec.start_date
                           OR l_eam_op_rec.completion_date<>l_old_eam_op_rec.completion_date)) THEN
			 --    l_eam_op_rec.start_date := l_old_eam_op_rec.start_date;      --set op dates to prev. dates
			 --    l_eam_op_rec.completion_date := l_old_eam_op_rec.completion_date;
			 x_bottomup_scheduled := G_BU_SCHEDULE_WO;
	    END IF;
	  END IF;


          EAM_OP_UTILITY_PVT.Perform_Writes
          (   p_eam_op_rec          => l_eam_op_rec
          ,   x_mesg_token_tbl      => l_mesg_token_tbl
          ,   x_return_status       => l_return_status
          ) ;


       IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
       THEN
          l_other_message := 'EAM_OP_WRITES_UNEXP_SKIP';
          l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
          l_other_token_tbl(1).token_value :=
                          l_eam_op_rec.OPERATION_SEQ_NUM ;
          RAISE EXC_UNEXP_SKIP_OBJECT ;
       ELSIF l_return_status ='S' AND
          l_mesg_token_tbl.COUNT <>0
       THEN
            l_out_eam_op_tbl            := l_eam_op_tbl;
            l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
            l_out_eam_res_tbl           := l_eam_res_tbl;
            l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
            l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
            l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
            l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_op_tbl             => l_eam_op_tbl
               ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => 'W'
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
               ,  p_entity_index           => I
               ,  x_eam_wo_rec             => l_eam_wo_rec
               ,  x_eam_op_tbl             => l_out_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
               );
	      l_eam_op_tbl                := l_out_eam_op_tbl;
	      l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	      l_eam_res_tbl               := l_out_eam_res_tbl;
	      l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	      l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	      l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
	      l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
	      l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;
       END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operations Database writes completed with status  ' || l_return_status); END IF;


          --find if scheduler is to be called or not
          IF(x_schedule_wo = G_NOT_SCHEDULE_WO) THEN
		     IF(l_eam_op_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE)
		      THEN   --if operation is added
			x_schedule_wo := G_SCHEDULE_WO;
		     END IF;
	   END IF;

	    --find if bottom up scheduler is to be called or not
          IF(x_bottomup_scheduled = G_NOT_BU_SCHEDULE_WO) THEN
		     IF(l_eam_op_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE)
		      THEN   --if operation is added
			  x_bottomup_scheduled := G_BU_SCHEDULE_WO;
		     END IF;
	   END IF;

    ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Skipping '|| I || ' record') ; END IF ;

    END IF; -- END IF statement that checks RETURN STATUS

    --  Load tables.
    l_eam_op_tbl(I)          := l_eam_op_rec;

    -- Indicate that children need to be processed
    l_process_children := TRUE;

    --  For loop exception handler.

    EXCEPTION
       WHEN EXC_SEV_QUIT_RECORD THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_direct_items_tbl      => l_eam_direct_items_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;

         l_process_children             := FALSE;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_SEV_QUIT_BRANCH THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_SEV_SKIP_BRANCH THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_SEV_QUIT_SIBLINGS THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         IF l_bo_return_status = 'S'
         THEN
             l_bo_return_status  := l_return_status ;
         END IF;
         x_return_status                := l_bo_return_status;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_FAT_QUIT_BRANCH THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_CHILDREN
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;



      WHEN EXC_FAT_QUIT_SIBLINGS THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_SIBLINGS
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  p_entity_index           => I
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;


         l_process_children             := FALSE ;
         x_return_status                := EAM_ERROR_MESSAGE_PVT.G_STATUS_FATAL;
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


      WHEN EXC_UNEXP_SKIP_OBJECT THEN
	         l_out_eam_op_tbl            := l_eam_op_tbl;
	  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	         l_out_eam_res_tbl           := l_eam_res_tbl;
	         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	         l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
       EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl        => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_OP_LEVEL
        ,  x_eam_wo_rec             => l_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	         l_eam_op_tbl                := l_out_eam_op_tbl;
	         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	         l_eam_res_tbl               := l_out_eam_res_tbl;
	         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
  	         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
  	         l_eam_direct_items_tbl         := l_out_eam_direct_items_tbl;


         l_return_status                := 'U';
         x_mesg_token_tbl               := l_mesg_token_tbl ;
         x_eam_op_tbl                   := l_eam_op_tbl;
         x_eam_op_network_tbl           := l_eam_op_network_tbl;
         x_eam_res_tbl                  := l_eam_res_tbl;
         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

   END ; -- END block

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   END IF;


   IF l_process_children
   THEN

      -- Process Resources that are direct children of this Operation
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling OPERATION_RESOURCES from WO_OPERATIONS') ; END IF ;

        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;



        OPERATION_RESOURCES
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_op_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_op_rec.organization_id
        ,  p_operation_seq_num             =>  l_eam_op_rec.operation_seq_num
        ,  p_eam_res_tbl                   =>  l_eam_res_tbl
        ,  p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
        ,  x_eam_res_tbl                   =>  l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl              =>  l_out_eam_res_inst_tbl
        ,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
	,  x_schedule_wo                   =>  x_schedule_wo
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_res_tbl           := l_out_eam_res_tbl;
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;


      -- Process Sub Resource that are direct children of this operation

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling SUB_RESOURCES from WO_OPERATIONS') ; END IF ;

        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;

      /*  SUB_RESOURCES
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_op_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_op_rec.organization_id
        ,  p_operation_seq_num             =>  l_eam_op_rec.operation_seq_num
        ,  p_eam_sub_res_tbl               =>  l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
        ,  x_eam_sub_res_tbl               =>  l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        ); */

        l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;


      -- Process Material requirements that are direct children of this Operation
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling MATERIAL_REQUIREMENTS from WO_OPERATIONS') ; END IF ;

        l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;

        MATERIAL_REQUIREMENTS
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_op_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_op_rec.organization_id
        ,  p_operation_seq_num             =>  l_eam_op_rec.operation_seq_num
        ,  p_department_id                 =>  l_eam_op_rec.department_id
        ,  p_eam_mat_req_tbl               =>  l_eam_mat_req_tbl
	,  x_material_shortage		   =>  x_material_shortage
        ,  x_eam_mat_req_tbl               =>  l_out_eam_mat_req_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;


   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;




      -- Process Direct Items that are direct children of this Operation
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling DIRECT_ITEMS
from WO_OPERATIONS') ; END IF ;

        l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;

        DIRECT_ITEMS
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_op_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_op_rec.organization_id
        ,  p_operation_seq_num             =>  l_eam_op_rec.operation_seq_num
        ,  p_department_id                 =>  l_eam_op_rec.department_id
        ,  p_eam_direct_items_tbl          =>  l_eam_direct_items_tbl
        ,  x_eam_direct_items_tbl          =>  l_out_eam_direct_items_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
	,  x_material_shortage		   =>  x_material_shortage
        );

        l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;


   IF l_return_status in ('Q', 'U')
   THEN
      x_return_status := l_return_status;
      RETURN ;
   ELSIF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;



   END IF;   -- Process children


   END LOOP; -- END Operation processing loop

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.WO_OPERATIONS : End Return status: '||NVL(l_return_status, 'S')||' ==========================') ; END IF ;

   --  Load OUT parameters
   IF NVL(l_return_status, 'S') <> 'S'
   THEN
      x_return_status     := l_return_status;
   END IF;

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

END WO_OPERATIONS;


PROCEDURE LOG_WORK_ORDER_HEADER (
  p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type) IS

 BEGIN

IF GET_DEBUG = 'Y' THEN
	EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_PROCESS_WO_PVT.LOG_WORK_ORDER_HEADER : Start========================== ');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('======================================================================================================================================================');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order                : '||p_eam_wo_rec.wip_entity_name);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Wip Entity Id             : '||p_eam_wo_rec.wip_entity_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Transaction Type          : '||p_eam_wo_rec.transaction_type ||' (1:Create / 2:Update / 3:Delete / 4:Complete / 5:UnComplete)');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Organization Id           : '||p_eam_wo_rec.organization_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Asset Number              : '||p_eam_wo_rec.asset_number);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Asset Group Id            : '||p_eam_wo_rec.asset_group_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Rebuildable Serial No     : '||p_eam_wo_rec.rebuild_serial_number);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Rebuildable Item Id       : '||p_eam_wo_rec.rebuild_item_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Activity Id               : '||p_eam_wo_rec.asset_activity_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Owning Department         : '||p_eam_wo_rec.owning_department);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('WIP Accounting ClassCode  : '||p_eam_wo_rec.class_code);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Workorder Description     : '||p_eam_wo_rec.description);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('System Status Id          : '||p_eam_wo_rec.status_type||' ( 17 : Draft / 1 : Unreleased / 3 : Released/4 : Complete - Charges allowed/ 5 :Complete - no charges allowed / 6 : Hold - no charges allowed)');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('                          :    ( 7  : Cancelled - no charges allowed / 12 : Closed - no charges allowed/ 14 :Pending Close / 15 : Failed Close)');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('User Defined Status Id    : '||p_eam_wo_rec.USER_DEFINED_STATUS_ID);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Job Quantity              : '||p_eam_wo_rec.job_quantity);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Workflow Type             : '||p_eam_wo_rec.workflow_type);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Scheduled Start date      : '||to_char(p_eam_wo_rec.scheduled_start_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Scheduled Completion Date : '||to_char(p_eam_wo_rec.scheduled_completion_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Released Date             : '|| to_char(p_eam_wo_rec.date_released,'DD-MON-YY HH:MI:SS'));

	EAM_ERROR_MESSAGE_PVT.Write_Debug('Gen Object Id             : '||p_eam_wo_rec.gen_object_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Parent Wip Entity Id      : '||p_eam_wo_rec.parent_wip_entity_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Maintenance Object id     : '||p_eam_wo_rec.maintenance_object_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Maintenance Object Type   : '||p_eam_wo_rec.maintenance_object_type || ' ( 2 : Non Serialized / 3: Serialized )');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Maintenance Object Source : '||p_eam_wo_rec.maintenance_object_source);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Activity Type             : '||p_eam_wo_rec.activity_type);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Activity Cause            : '||p_eam_wo_rec.activity_cause);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Activity Source           : '||p_eam_wo_rec.activity_source);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('WorkOrder Type            : '||p_eam_wo_rec.work_order_type);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Shutdown Type             : '||p_eam_wo_rec.shutdown_type);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Firm Planned Flag         : '||p_eam_wo_rec.firm_planned_flag);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Notification Required     : '||p_eam_wo_rec.notification_required);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Tagout Required           : '||p_eam_wo_rec.tagout_required);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Workorder Priority        : '||p_eam_wo_rec.priority);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Plan Maintenance          : '||p_eam_wo_rec.plan_maintenance);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Project Id                : '||p_eam_wo_rec.project_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Task Id                   : '||p_eam_wo_rec.task_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Pending Flag              : '||p_eam_wo_rec.pending_flag || '(Y : Yes / N : No / '' '': No)');
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Material Shortage Flag    : '||p_eam_wo_rec.material_shortage_flag);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Material_issue_by_mo      : '||p_eam_wo_rec.material_issue_by_mo);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('PM Suggested Start Date   : '||to_char(p_eam_wo_rec.pm_suggested_start_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('PM Suggested End Date     : '||to_char(p_eam_wo_rec.pm_suggested_end_date,'DD-MON-YY HH:MI:SS'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('PM Schedule Id            : '||p_eam_wo_rec.pm_schedule_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('PM Base Meter Reading     : '||p_eam_wo_rec.pm_base_meter_reading);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('PM Base Meter             : '||p_eam_wo_rec.pm_base_meter);

	EAM_ERROR_MESSAGE_PVT.Write_Debug('Actual Close Date         : '||to_char(p_eam_wo_rec.actual_close_date,'DD-MON-YY HH:MI:SS'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Mat Shortage Check Date   : '||to_char(p_eam_wo_rec.material_shortage_check_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Due Date                  : '||to_char(p_eam_wo_rec.due_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Submission Date           : '||to_char(p_eam_wo_rec.submission_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Requested Start Date      : '||to_char(p_eam_wo_rec.requested_start_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Schedule GroupId          : '||p_eam_wo_rec.schedule_group_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('AlternateRoutingDesignator: '||p_eam_wo_rec.alternate_routing_designator);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Alternate BOM Designator  : '||p_eam_wo_rec.alternate_bom_designator);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('BOM Revision Date         : '||to_char(p_eam_wo_rec.bom_revision_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Routing Revision Date     : '||to_char(p_eam_wo_rec.routing_revision_date,'dd-mon-yy hh:mi:ss'));
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Routing Revision          : '||p_eam_wo_rec.routing_revision);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('BOM Revision              : '||p_eam_wo_rec.bom_revision );
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Common BOM Sequence Id    : '||p_eam_wo_rec.common_bom_sequence_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Common Routing Sequence Id: '||p_eam_wo_rec.common_routing_sequence_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('End Item Unit Number      : '||p_eam_wo_rec.end_item_unit_number);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Report Type               : '||p_eam_wo_rec.report_type);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Wip Supply Type           : '||p_eam_wo_rec.wip_supply_type);

	EAM_ERROR_MESSAGE_PVT.Write_Debug('Material Account          : '||p_eam_wo_rec.material_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Material Overhead Account : '||p_eam_wo_rec.material_overhead_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Resource Account          : '||p_eam_wo_rec.resource_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Outside Processing Account: '||p_eam_wo_rec.outside_processing_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Material Variance Account : '||p_eam_wo_rec.material_variance_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Resource Cariance Account : '||p_eam_wo_rec.resource_variance_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('OutsideProcVarianceAccount: '||p_eam_wo_rec.outside_proc_variance_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Std Cost AdjustmentAccount: '||p_eam_wo_rec.std_cost_adjustment_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Overhead Account          : '||p_eam_wo_rec.overhead_account);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Overhead Variance Account : '||p_eam_wo_rec.overhead_variance_account);

	EAM_ERROR_MESSAGE_PVT.Write_Debug('Wip Supply Type           : '||p_eam_wo_rec.wip_supply_type);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('PO Creation Time          : '||p_eam_wo_rec.po_creation_time);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Cycle Id                  : '||p_eam_wo_rec.cycle_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Sequence Id               : '||p_eam_wo_rec.seq_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Warranty Claim Status     : '||p_eam_wo_rec.warranty_claim_status);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Warranty Active           : '||p_eam_wo_rec.warranty_active);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Assignment Complete       : '||p_eam_wo_rec.assignment_complete);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Validate Structure        : '||p_eam_wo_rec.validate_structure);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Eam Linear Location Id    : '||p_eam_wo_rec.eam_linear_location_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Failure Code Required     : '||p_eam_wo_rec.failure_code_required);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Issue Zero Cost Flag      : '||p_eam_wo_rec.issue_zero_cost_flag);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('DS Scheduled Flag         : '||p_eam_wo_rec.ds_scheduled_flag);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Manual Rebuild Flag       : '||p_eam_wo_rec.manual_rebuild_flag);

	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute Category        : '||p_eam_wo_rec.attribute_category);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute1                : '||p_eam_wo_rec.attribute1);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute2                : '||p_eam_wo_rec.attribute2);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute3                : '||p_eam_wo_rec.attribute3);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute4                : '||p_eam_wo_rec.attribute4);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute5                : '||p_eam_wo_rec.attribute5);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute6                : '||p_eam_wo_rec.attribute6);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute7                : '||p_eam_wo_rec.attribute7);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute8                : '||p_eam_wo_rec.attribute8);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute9                : '||p_eam_wo_rec.attribute9);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute10               : '||p_eam_wo_rec.attribute10);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute11               : '||p_eam_wo_rec.attribute11);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute12               : '||p_eam_wo_rec.attribute12);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute13               : '||p_eam_wo_rec.attribute13);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute14               : '||p_eam_wo_rec.attribute14);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Attribute15               : '||p_eam_wo_rec.attribute15);

	EAM_ERROR_MESSAGE_PVT.Write_Debug('Source Code               : '||p_eam_wo_rec.source_code);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Source Line Id            : '||p_eam_wo_rec.source_line_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('User Id                   : '||p_eam_wo_rec.user_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Responsibility_id         : '||p_eam_wo_rec.responsibility_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Request Id                : '||p_eam_wo_rec.request_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Program_id                : '||p_eam_wo_rec.program_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('Program Application Id    : '||p_eam_wo_rec.program_application_id);
	EAM_ERROR_MESSAGE_PVT.Write_Debug('===============================================================================================================');
	EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_PROCESS_WO_PVT.LOG_WORK_ORDER_HEADER : End========================== ');

 END IF;
 EXCEPTION
WHEN OTHERS THEN
	NULL;

END LOG_WORK_ORDER_HEADER;


-------
PROCEDURE WORK_ORDER
         ( p_validation_level        IN  NUMBER
         , p_eam_wo_rec              IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
	 , p_wip_entity_id           IN  NUMBER
         , p_eam_op_tbl              IN EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl         IN EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	 , x_schedule_wo             IN OUT NOCOPY NUMBER
 	 , x_bottomup_scheduled      IN OUT NOCOPY NUMBER
  	 , x_material_shortage       IN OUT NOCOPY NUMBER
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
IS
        l_api_version_number    CONSTANT NUMBER := 1.0;
        l_api_name              CONSTANT VARCHAR2(30):= 'EAM_PROCESS_WO_PVT';
        l_err_text              VARCHAR2(240);

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_old_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type         :=p_eam_op_tbl;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type :=p_eam_op_network_tbl;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type        :=p_eam_res_tbl;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type   :=p_eam_res_inst_tbl;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type    :=p_eam_sub_res_tbl;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type  :=p_eam_res_usage_tbl;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type    :=p_eam_mat_req_tbl;
        l_eam_direct_items_tbl       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type    :=p_eam_direct_items_tbl;

        -- baroy - added for making the NOCOPY changes
        l_out_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl                 EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl         EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl                EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl           EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl            EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl          EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl            EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_direct_items_tbl            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;


        l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_mesg_token_tbl             EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_other_message         VARCHAR2(20000);
        l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_error_text            VARCHAR2(2000);
        l_valid_transaction     BOOLEAN := TRUE;
        l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_pick_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_msg_count             NUMBER := 0;

        l_bo_return_status      VARCHAR2(1) := 'S';
        l_return_value          NUMBER;
        l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        EXC_ERR_PVT_API_MAIN    EXCEPTION;
        POPULATE_RELEASE_ERR         EXCEPTION;
        G_ERR_STATUS_CHANGE          EXCEPTION;

        l_start_date		date;
        l_completion_date	date;
	l_firm_planned_flag     NUMBER;
	l_wip_entity_id		NUMBER;
	l_request_id		NUMBER;
	l_errbuf		VARCHAR2(2000) ;
	l_retcode		NUMBER := 0;
	l_workflow_enabled VARCHAR2(1);
	l_status_pending_event VARCHAR2(240);
	l_approval_required     BOOLEAN;
	l_pending_workflow_name              VARCHAR2(100);
	l_pending_workflow_process           VARCHAR2(200);
	 l_pending_flag   VARCHAR2(1);
	 l_new_system_status         NUMBER;
	l_msg_data		VARCHAR2(2000);
	x_shortage_exists	VARCHAR2(1);
        l_current_status        NUMBER;
	l_serial_number         VARCHAR2(30);
	l_inv_item_id           NUMBER;
	l_org_id                NUMBER;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;

	l_count number :=0;
	l_min_open_period_date         DATE;
	l_estimation_staus number;
	l_count_assetActAssoc number;
	l_asset_changed varchar2(1):='N';
	l_already_estimated varchar2(1):='N';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_wip_entity_id:=p_wip_entity_id;

   -- baroy - Skip the header validations if header is null
   -- If condition #101
   IF p_eam_wo_rec.transaction_type is not null then

    -- Begin block that processes header.
    -- This block holds the exception handlers for header errors.


   l_status_pending_event               :=      'oracle.apps.eam.workorder.status.change.pending';
   l_approval_required := FALSE;      --set the flag to 'false' initially


    BEGIN
IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_PROCESS_WO_PVT.WORK_ORDER : Start =========================================================');  END IF;

	LOG_WORK_ORDER_HEADER
	( p_eam_wo_rec => p_eam_wo_rec
	);

        --  Load entity and record-specific details into system_information record

        l_eam_wo_rec            := p_eam_wo_rec;

        IF l_eam_wo_rec.return_status IS NOT NULL AND
           l_eam_wo_rec.return_status <> FND_API.G_MISS_CHAR
        THEN
                x_return_status                := l_return_status;
                x_eam_wo_rec                   := l_eam_wo_rec;
                x_eam_op_tbl                   := l_eam_op_tbl;
                x_eam_op_network_tbl           := l_eam_op_network_tbl;
                x_eam_res_tbl                  := l_eam_res_tbl;
                x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
                x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
                x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
                x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
                x_eam_direct_items_tbl              := l_eam_direct_items_tbl;
                RETURN;
        END IF;

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_eam_wo_rec.return_status := FND_API.G_RET_STS_SUCCESS;


IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Work Order: Transaction Type Validity . . . ');  END IF;

        VALIDATE_TRANSACTION_TYPE
        (   p_transaction_type  => l_eam_wo_rec.transaction_type
        ,   p_entity_name       => 'WORK_ORDER'
        ,   p_entity_id         => l_eam_wo_rec.wip_entity_name
        ,   x_valid_transaction => l_valid_transaction
        ,   x_mesg_token_tbl    => l_Mesg_Token_Tbl
        );

        IF NOT l_valid_transaction
        THEN
            l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
            RAISE EXC_SEV_QUIT_RECORD;
        END IF;

IF GET_DEBUG = 'Y' THEN   EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : EAM WO: Check Existence . . .');  END IF;

            EAM_WO_VALIDATE_PVT.Check_Existence
            ( p_eam_wo_rec             => l_eam_wo_rec
            , x_old_eam_wo_rec         => l_old_eam_wo_rec
            , x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
            , x_return_status          => l_Return_Status
             );

        IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        THEN
            l_other_message := 'EAM_WO_EXS_SEV_ERROR';
            l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
            l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
            RAISE EXC_SEV_QUIT_BRANCH;
        ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN
            l_other_message := 'EAM_WO_EXS_UNEXP_SKIP';
            l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
            l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
            RAISE EXC_UNEXP_SKIP_OBJECT;
        END IF;

        /* Assign the correct transaction type for SYNC operations */

        IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
           l_eam_wo_rec.transaction_type := l_old_eam_wo_rec.transaction_type;
        END IF;

              --Changes for IB
       --If this is a work order on a predefined rebuild, create an instance for it NOW
       --If this is a automatic rebuild work order and the serial number has just been provided, update NOW

          IF ((l_eam_wo_rec.rebuild_serial_number is not null and l_eam_wo_rec.rebuild_serial_number <> FND_API.G_MISS_CHAR )or l_eam_wo_rec.asset_number is not null ) then
                select msn.current_status
                into l_current_status
                from mtl_serial_numbers msn
                where inventory_item_id = nvl(l_eam_wo_rec.rebuild_item_id, l_eam_wo_rec.asset_group_id)
                and serial_number = nvl(l_eam_wo_rec.rebuild_serial_number, l_eam_wo_rec.asset_number);

                IF (l_current_status = 1 OR l_eam_wo_rec.maintenance_object_type = 2) THEN
IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER :  Calling EAM_COMMON_UTILITIES_PVT.CREATE_ASSET procedure . . .'); END IF;
                        EAM_COMMON_UTILITIES_PVT.CREATE_ASSET(
                         P_API_VERSION              => 1.0
                        ,P_INIT_MSG_LIST            => fnd_api.g_false
                        ,P_COMMIT                   => fnd_api.g_false
                        ,P_VALIDATION_LEVEL        => fnd_api.g_valid_level_full
                        ,X_EAM_WO_REC               => l_eam_wo_rec
                        ,X_RETURN_STATUS            => l_return_status
                        ,X_MSG_COUNT                => l_msg_count
                        ,X_MSG_DATA                 => l_error_text
               );

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                l_other_message := 'EAM_IB_INST_FAILED';
            	l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
            	l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
            	RAISE EXC_UNEXP_SKIP_OBJECT;

               END IF;

                END IF;

       END IF;


       IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Checking whether asset number is changed: New Asset: '||l_eam_wo_rec.asset_number||' Old Asset: '||l_old_eam_wo_rec.asset_number) ; END IF;
       if(p_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE and (l_old_eam_wo_rec.asset_number <> l_eam_wo_rec.asset_number or  l_eam_wo_rec.MAINTENANCE_OBJECT_ID <> l_old_eam_wo_rec.MAINTENANCE_OBJECT_ID)) then

           l_asset_changed :='Y';
           if(l_old_eam_wo_rec.asset_activity_id is not null) then

       		SELECT
       	          count(*) into l_count_assetActAssoc
       		FROM
                 mtl_eam_asset_activities meaa
       		WHERE
                 meaa.maintenance_object_type = 3
                 AND  meaa.asset_activity_id = p_eam_wo_rec.asset_activity_id
                 AND  meaa.maintenance_object_id = p_eam_wo_rec.maintenance_object_id;

                if(l_count_assetActAssoc = 0) then
                	l_eam_wo_rec.asset_activity_id := FND_API.G_MISS_NUM;
                end if;
           end if;

           if(l_eam_wo_rec.owning_department IS NULL) THEN
                l_eam_wo_rec.owning_department := FND_API.G_MISS_NUM;
           end if;

           select estimation_status into l_estimation_staus
           from   wip_discrete_jobs
           WHERE wip_entity_id=l_eam_wo_rec.wip_entity_id
           AND organization_id=l_eam_wo_rec.organization_id;

           if(l_estimation_staus = 7) then
          	l_already_estimated := 'Y';
          	CSTPECEP.Estimate_WorkOrder_Grp(
                             p_api_version => 1.0,
                             p_init_msg_list => fnd_api.g_false,
                             p_commit  =>  fnd_api.g_false,
                             p_validation_level  => fnd_api.g_valid_level_full,
                             p_wip_entity_id => l_eam_wo_rec.wip_entity_id,
                             p_organization_id => l_eam_wo_rec.organization_id,
                             x_return_status      => l_return_status,
                             x_msg_data           => l_err_text,
                             x_msg_count          => l_msg_count,
                             p_delete_only        => 'Y');

            IF GET_DEBUG = 'Y' THEN    EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : After call CSTPECEP.Estimate_WorkOrder_Grp to delete existing estimate. status :' ||l_return_status) ; END IF;
      	   end if;

            -- deleting earlier failure data if exists

           Eam_Process_Failure_Entry_PVT.Delete_Failure_Entry
           ( p_api_version                => 1.0,
             p_init_msg_list              => fnd_api.g_false,
             p_commit                     => fnd_api.g_false,
             p_source_id                  => l_eam_wo_rec.wip_entity_id,
             x_return_status              => l_return_status,
             x_msg_count                  => l_msg_count,
             x_msg_data                   => l_err_text
           );

      end if;

        IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE THEN
	      x_material_shortage := G_MATERIAL_UPDATE;
	END IF;

        IF l_eam_wo_rec.Transaction_Type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE)
        THEN

IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Populate Null Columns . . .'); END IF;
             l_out_eam_wo_rec := l_eam_wo_rec;
             EAM_WO_DEFAULT_PVT.Populate_NULL_Columns
                (   p_eam_wo_rec         => l_eam_wo_rec
                ,   p_old_eam_wo_rec     => l_old_eam_wo_rec
                ,   x_eam_wo_rec         => l_out_eam_wo_rec
                );
              l_eam_wo_rec := l_out_eam_wo_rec;

	      IF l_eam_wo_rec.STATUS_TYPE <> l_old_eam_wo_rec.STATUS_TYPE THEN
		      x_material_shortage := G_MATERIAL_UPDATE;
	      END IF;

        END IF;


IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Check_Attributes_Before_Defauting ... '); END IF;

        EAM_WO_VALIDATE_PVT.Check_Attributes_b4_Defaulting
                (   x_return_status     => l_return_status
                ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,   p_eam_wo_rec        => l_eam_wo_rec
                );

        IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        THEN

            IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
                l_other_message := 'EAM_WO_ATTVAL_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
                l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;

        ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN
            l_other_message := 'EAM_WO_ATTVAL_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
            RAISE EXC_UNEXP_SKIP_OBJECT;

        ELSIF l_return_status ='S' AND l_Mesg_Token_Tbl.COUNT <>0
        THEN

	    l_out_eam_wo_rec            := l_eam_wo_rec;
	    l_out_eam_op_tbl            := l_eam_op_tbl;
	    l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
	    l_out_eam_res_tbl           := l_eam_res_tbl;
	    l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	    l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
	    l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
	    l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
	    l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
	    l_out_eam_direct_items_tbl     := l_eam_direct_items_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
            (  p_eam_wo_rec             => l_eam_wo_rec
            ,  p_eam_op_tbl             => l_eam_op_tbl
            ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
            ,  p_eam_res_tbl            => l_eam_res_tbl
            ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
            ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
            ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
            ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
            ,  p_mesg_token_tbl         => l_mesg_token_tbl
            ,  p_error_status           => 'W'
            ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
            ,  x_eam_wo_rec             => l_out_eam_wo_rec
            ,  x_eam_op_tbl             => l_out_eam_op_tbl
            ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
            ,  x_eam_res_tbl            => l_out_eam_res_tbl
            ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
            ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
            ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
            ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
            );
	    l_eam_wo_rec                := l_out_eam_wo_rec;
	    l_eam_op_tbl                := l_out_eam_op_tbl;
	    l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
	    l_eam_res_tbl               := l_out_eam_res_tbl;
	    l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
	    l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
	    l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
	    l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
  	    l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        END IF;

IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Conditional Defaulting . . .'); END IF;
        l_out_eam_wo_rec := l_eam_wo_rec;
        EAM_WO_DEFAULT_PVT.Conditional_Defaulting
                (   p_eam_wo_rec        => l_eam_wo_rec
                ,   x_eam_wo_rec        => l_out_eam_wo_rec
                ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,   x_return_status     => l_Return_Status
                );
        l_eam_wo_rec := l_out_eam_wo_rec;

        IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        THEN
                IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                    l_other_message := 'EAM_WO_CONDDEF_CSEV_SKIP';
                    l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
                    l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                    RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                    RAISE EXC_SEV_QUIT_RECORD;
                END IF;

        ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'EAM_WO_CONDDEF_UNEXP_SKIP';
                l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
                l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND l_Mesg_Token_Tbl.COUNT <>0
        THEN

	        l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
  	        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
                );
	        l_eam_wo_rec                := l_out_eam_wo_rec;
                l_eam_op_tbl                := l_out_eam_op_tbl;
                l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
                l_eam_res_tbl               := l_out_eam_res_tbl;
                l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
                l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
                l_eam_direct_items_tbl      := l_out_eam_direct_items_tbl;
                l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        END IF;

IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Attribute Defaulting . . .'); END IF;

        l_out_eam_wo_rec := l_eam_wo_rec;
	/* Bug # 4597756 : Store firm_planned_flag, needed if Approval is required */
	l_firm_planned_flag := l_eam_wo_rec.firm_planned_flag;
        EAM_WO_DEFAULT_PVT.Attribute_Defaulting
                (   p_eam_wo_rec        => l_eam_wo_rec
		,    p_old_eam_wo_rec   =>    l_old_eam_wo_rec
                ,   x_eam_wo_rec        => l_out_eam_wo_rec
                ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,   x_return_status     => l_Return_Status
                );
             l_eam_wo_rec := l_out_eam_wo_rec;

        IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        THEN

                IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                    l_other_message := 'EAM_WO_ATTDEF_CSEV_SKIP';
                    l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
                    l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                    RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                    RAISE EXC_SEV_QUIT_RECORD;
                END IF;

        ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN
                l_other_message := 'EAM_WO_ATTDEF_UNEXP_SKIP';
                l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
                l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                RAISE EXC_UNEXP_SKIP_OBJECT;
        ELSIF l_return_status ='S' AND l_Mesg_Token_Tbl.COUNT <>0
        THEN

	        l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
  	        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
                ,  p_mesg_token_tbl         => l_mesg_token_tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
                );
	       l_eam_wo_rec                := l_out_eam_wo_rec;
               l_eam_op_tbl                := l_out_eam_op_tbl;
               l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
               l_eam_res_tbl               := l_out_eam_res_tbl;
               l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
               l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
               l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
               l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
               l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        END IF;

        EAM_WO_VALIDATE_PVT.Check_Required
        (  p_eam_wo_rec        => l_eam_wo_rec
        ,  x_return_status     => l_return_status
        ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
         );

        IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        THEN

            IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
                l_other_message := 'EAM_WO_CONREQ_CSEV_SKIP';
                l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
                l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                RAISE EXC_SEV_SKIP_BRANCH;

            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;

        ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN

        l_other_message := 'EAM_WO_CONREQ_UNEXP_SKIP';
        l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
        l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
        RAISE EXC_UNEXP_SKIP_OBJECT;

        ELSIF l_return_status ='S' AND l_Mesg_Token_Tbl.COUNT <>0
        THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
            (  p_eam_wo_rec             => l_eam_wo_rec
            ,  p_eam_op_tbl             => l_eam_op_tbl
            ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
            ,  p_eam_res_tbl            => l_eam_res_tbl
            ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
            ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
            ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
            ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
            ,  p_mesg_token_tbl         => l_mesg_token_tbl
            ,  p_error_status           => 'W'
            ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
            ,  x_eam_wo_rec             => l_out_eam_wo_rec
            ,  x_eam_op_tbl             => l_out_eam_op_tbl
            ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
            ,  x_eam_res_tbl            => l_out_eam_res_tbl
            ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
            ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
            ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
            ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
             );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
        END IF;

IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Check Attributes . . .'); END IF;

        EAM_WO_VALIDATE_PVT.Check_Attributes
            (   x_return_status            => l_return_status
            ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
            ,   p_eam_wo_rec               => l_eam_wo_rec
            ,   p_old_eam_wo_rec           => l_old_eam_wo_rec
            );
     IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        THEN

            IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            THEN
                l_other_message := 'EAM_WO_ATTVAL_CSEV_SKIP';
                l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
                l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                RAISE EXC_SEV_SKIP_BRANCH;
            ELSE
                RAISE EXC_SEV_QUIT_RECORD;
            END IF;

        ELSIF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN
            l_other_message := 'EAM_WO_ATTVAL_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
            RAISE EXC_UNEXP_SKIP_OBJECT;

        ELSIF l_return_status ='S' AND l_Mesg_Token_Tbl.COUNT <>0
        THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
            (  p_eam_wo_rec             => l_eam_wo_rec
            ,  p_eam_op_tbl             => l_eam_op_tbl
            ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
            ,  p_eam_res_tbl            => l_eam_res_tbl
            ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
            ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
            ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
            ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
            ,  p_mesg_token_tbl         => l_mesg_token_tbl
            ,  p_error_status           => 'W'
            ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
            ,  x_eam_wo_rec             => l_out_eam_wo_rec
            ,  x_eam_op_tbl             => l_out_eam_op_tbl
            ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
            ,  x_eam_res_tbl            => l_out_eam_res_tbl
            ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
            ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
            ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
            ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
            );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        END IF;

--      Explode Activity

        IF (l_eam_wo_rec.asset_activity_id IS NOT NULL) and
           ((l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) or
           (l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE and
  --fix for 3296919.added following condition so that activity is updateable
            (l_old_eam_wo_rec.asset_activity_id is null OR l_old_eam_wo_rec.asset_activity_id<>l_eam_wo_rec.asset_activity_id)))
        THEN

          IF EAM_OP_UTILITY_PVT.NUM_OF_ROW
             ( p_eam_op_tbl         => l_eam_op_tbl
             , p_wip_entity_id      => p_eam_wo_rec.wip_entity_id
             , p_organization_id    => p_eam_wo_rec.organization_id
             )
          THEN

            l_out_eam_wo_rec            := l_eam_wo_rec;
            l_out_eam_op_tbl            := l_eam_op_tbl;
            l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
            l_out_eam_res_tbl           := l_eam_res_tbl;
            l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
            l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
            l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;

            EAM_EXPLODE_ACTIVITY_PVT.EXPLODE_ACTIVITY
            (  p_validation_level         =>  p_validation_level
            ,  p_eam_wo_rec               =>  l_eam_wo_rec
            ,  p_eam_op_tbl               =>  l_eam_op_tbl
            ,  p_eam_op_network_tbl       =>  l_eam_op_network_tbl
            ,  p_eam_res_tbl              =>  l_eam_res_tbl
            ,  p_eam_res_inst_tbl         =>  l_eam_res_inst_tbl
            ,  p_eam_sub_res_tbl          =>  l_eam_sub_res_tbl
            ,  p_eam_res_usage_tbl        =>  l_eam_res_usage_tbl
            ,  p_eam_mat_req_tbl          =>  l_eam_mat_req_tbl
            ,  x_eam_wo_rec               =>  l_out_eam_wo_rec
            ,  x_eam_op_tbl               =>  l_out_eam_op_tbl
            ,  x_eam_op_network_tbl       =>  l_out_eam_op_network_tbl
            ,  x_eam_res_tbl              =>  l_out_eam_res_tbl
            ,  x_eam_res_inst_tbl         =>  l_out_eam_res_inst_tbl
            ,  x_eam_sub_res_tbl          =>  l_out_eam_sub_res_tbl
            ,  x_eam_res_usage_tbl        =>  l_out_eam_res_usage_tbl
            ,  x_eam_mat_req_tbl          =>  l_out_eam_mat_req_tbl
            ,  x_mesg_token_tbl           =>  l_mesg_token_tbl
            ,  x_return_status            =>  l_return_status
            );

            l_eam_wo_rec            := l_out_eam_wo_rec;
            l_eam_op_tbl            := l_out_eam_op_tbl;
            l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
            l_eam_res_tbl           := l_out_eam_res_tbl;
            l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
            l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
            l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
            l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;

            -- if the explosion nullified the values of activity type,
            -- source and cause, then use the user provided values.
            if l_eam_wo_rec.activity_cause is null then
              l_eam_wo_rec.activity_cause := p_eam_wo_rec.activity_cause;
            end if;
            if l_eam_wo_rec.activity_type is null then
              l_eam_wo_rec.activity_type := p_eam_wo_rec.activity_type;
            end if;
            if l_eam_wo_rec.activity_source is null then
              l_eam_wo_rec.activity_source := p_eam_wo_rec.activity_source;
            end if;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug (' EAM_PROCESS_WO_PVT.WORK_ORDER : Calling api to update material shortage flag') ; END IF;


            IF nvl(l_return_status,'S') <> 'S' THEN
              x_return_status := l_return_status;
            END IF;

          ELSE

                IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                    l_other_message := 'EAM_WO_ACTEXP_CSEV_SKIP';
                    l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
                    l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
                    RAISE EXC_SEV_SKIP_BRANCH;
                ELSE
                    RAISE EXC_SEV_QUIT_RECORD;
                END IF;

          END IF;

        END IF;


--Handle status change approval

      l_workflow_enabled := Is_Workflow_Enabled(l_eam_wo_rec.maintenance_object_source,
                                                                                         l_eam_wo_rec.organization_id);

       IF(l_workflow_enabled = 'Y') THEN
                IF((l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE )  --created
		    OR (l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE  --workorder updated
			     AND NVL(l_old_eam_wo_rec.pending_flag,'N') = 'N'   --old status is not pending
			     --and old status is not same as new status
		            AND (l_old_eam_wo_rec.status_type <>l_eam_wo_rec.status_type)
			    )
		    ) THEN
		           IF(WF_EVENT.TEST(l_status_pending_event) <> 'NONE') THEN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Calling Wkflow required check API...') ; END IF;
							 EAM_WORKFLOW_DETAILS_PUB.Eam_Wf_Is_Approval_Required(p_old_wo_rec =>  l_old_eam_wo_rec,
															   p_new_wo_rec  =>  l_eam_wo_rec,
															   p_wip_entity_id              => NULL,
															   p_new_system_status   =>   NULL,
															   p_new_wo_status           =>   NULL,
															   p_old_system_status      =>   NULL,
															    p_old_wo_status             =>   NULL,
															   x_approval_required  =>  l_approval_required,
															   x_workflow_name   =>   l_pending_workflow_name,
															   x_workflow_process    =>   l_pending_workflow_process
															   );

						IF(l_approval_required) THEN
							    l_eam_wo_rec.pending_flag:='Y';   --if approval required set the pending flag and system status to previous status
							    l_new_system_status :=    l_eam_wo_rec.status_type;
							    l_eam_wo_rec.status_type := NVL(l_old_eam_wo_rec.status_type,17);
							    /* Bug # 4597756 : revert back the firm_planned_flag */
							    IF l_firm_planned_flag IS NULL OR l_firm_planned_flag = FND_API.G_MISS_NUM THEN
							       l_eam_wo_rec.firm_planned_flag := 2;
							    ELSE
							       l_eam_wo_rec.firm_planned_flag := l_firm_planned_flag;
							    END IF;
						END IF;
			   END IF; --end of check for status event enabled

		 END IF;
       END IF; -- end of check for workflow enabled

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : Writing the WO Record to database...') ; END IF;

        if ((l_eam_wo_rec.pm_suggested_start_date is null or
		     l_eam_wo_rec.pm_suggested_start_date = FND_API.G_MISS_DATE)
		    and (l_eam_wo_rec.pm_suggested_end_date is null or
				 l_eam_wo_rec.pm_suggested_end_date = FND_API.G_MISS_DATE)
			and l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
			) then
	      select pm_suggested_start_date, pm_suggested_end_date into
		    l_eam_wo_rec.pm_suggested_start_date,
			l_eam_wo_rec.pm_suggested_end_date
			from eam_work_order_details
			where wip_entity_id = l_eam_wo_rec.wip_entity_id;
	    end if;

        EAM_WO_UTILITY_PVT.PERFORM_WRITES
        (   p_eam_wo_rec            => l_eam_wo_rec
        ,   x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
        ,   x_return_status         => l_return_status
         );

        IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        THEN

            l_other_message := 'EAM_WO_WRITES_UNEXP_SKIP';
            l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;

        RAISE EXC_UNEXP_SKIP_OBJECT;

        ELSIF l_return_status ='S' AND l_Mesg_Token_Tbl.COUNT <>0
        THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
            EAM_ERROR_MESSAGE_PVT.Log_Error
            (  p_eam_wo_rec             => l_eam_wo_rec
            ,  p_eam_op_tbl             => l_eam_op_tbl
            ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
            ,  p_eam_res_tbl            => l_eam_res_tbl
            ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
            ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
            ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
            ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
            ,  p_mesg_token_tbl         => l_mesg_token_tbl
            ,  p_error_status           => 'W'
            ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
            ,  x_eam_wo_rec             => l_out_eam_wo_rec
            ,  x_eam_op_tbl             => l_out_eam_op_tbl
            ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
            ,  x_eam_res_tbl            => l_out_eam_res_tbl
            ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
            ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
            ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
            ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
            );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

	/* Bug # 4926626 : Disable hiearchy if automatic (replaced) rebuild WO is updated
	   with the Asset Number and parent WO is completed */
        IF (l_eam_wo_rec.parent_wip_entity_id IS NOT NULL AND
	    l_eam_wo_rec.manual_rebuild_flag = 'N' AND
	     l_eam_wo_rec.maintenance_object_type = 3 ) THEN

          IF (l_old_eam_wo_rec.maintenance_object_type = 2 AND
	      l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE) THEN

             SELECT serial_number, inventory_item_id, last_vld_organization_id
  	       INTO l_serial_number, l_inv_item_id, l_org_id
	       FROM csi_item_instances
	      WHERE instance_id = l_eam_wo_rec.maintenance_object_id;

            IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling api to endate eam genealogy') ; END IF;

	     wip_eam_genealogy_pvt.update_eam_genealogy
	     (
		p_api_version => 1.0,
		p_object_type => 2,
		p_serial_number => l_serial_number,
		p_inventory_item_id => l_inv_item_id,
		p_organization_id => l_org_id,
		p_genealogy_type => 5,
		p_end_date_active => sysdate,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data
	     );
            IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : Update Genealogy completed with status '||l_return_status) ; END IF;

	     IF l_return_status <> 'S' THEN
                  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	            EAM_ERROR_MESSAGE_PVT.Write_Debug ('api for endating eam genealogy has errored') ;
	          END IF;
	 	  l_other_message := 'EAM_UPDATE_GENEALOGY_FAIL';
		  RAISE EXC_SEV_QUIT_RECORD;
             END IF;

          END IF;

	  IF ((l_old_eam_wo_rec.maintenance_object_type = 2 AND l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UPDATE) OR
	        (l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE )) THEN

             /* If the parent WO is complete, disable meter hierarchy and IB hierarchy */
	     SELECT status_type INTO l_current_status
	       FROM wip_discrete_jobs
	      WHERE wip_entity_id = l_eam_wo_rec.parent_wip_entity_id;

             IF (l_current_status in (4, 5, 12) ) THEN

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling api to disable counter hierarchy') ; END IF;

	        eam_meterreading_utility_pvt.disable_counter_hierarchy
	        (
		  p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl ,
		  p_subinventory_id	  => null,
		  p_wip_entity_id           => l_eam_wo_rec.parent_wip_entity_id,
		  x_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl,
		  x_return_status           => l_return_status ,
		  x_mesg_token_tbl	  => l_mesg_token_tbl
	        );
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER :  disable counter hierarchy API completed with status '||l_return_status) ; END IF;

	        IF l_return_status <> 'S' THEN

		  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
  	             EAM_ERROR_MESSAGE_PVT.Write_Debug ('The api to disable counter hierarchy has errored out') ;
   	          END IF;
		  l_other_message := 'EAM_WOCMPL_DIS_COUNTER_HIER';
		  l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		  l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
		  RAISE EXC_SEV_QUIT_RECORD;
                END IF;

                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling CSI api for wip completion ') ; END IF;

	        csi_eam_interface_grp.wip_completion
	        (
		 p_wip_entity_id   => l_eam_wo_rec.parent_wip_entity_id,
		 p_organization_id => l_eam_wo_rec.organization_id,
		 x_return_status   => l_return_status,
		 x_error_message   => l_msg_data
  	        );
                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : CSI api for wip completion completed with status '||l_return_status) ; END IF;

	        IF l_return_status <> 'S' THEN

		  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
	            EAM_ERROR_MESSAGE_PVT.Write_Debug ('EAM_PROCESS_WO_PVT.WORK_ORDER : The CSI api for wip completion has errored out') ;
	          END IF;

		  l_other_message := 'EAM_WOCMPL_IB_WIP_CMPL';
		  l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		  l_other_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_name;
		  RAISE EXC_SEV_QUIT_RECORD;
                END IF;
	     END IF;

          END IF;


        END IF;


    EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        x_return_status                := l_return_status;
        x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;
	RETURN;

    WHEN EXC_SEV_QUIT_BRANCH THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        x_return_status                := l_return_status;
        x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

    RETURN;

    WHEN EXC_SEV_SKIP_BRANCH THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        x_return_status                := l_return_status;
        x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

    RETURN;


    WHEN EXC_FAT_QUIT_OBJECT THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        x_return_status                := l_return_status;
        x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

    l_return_status := 'Q';
    	RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        x_return_status                := l_return_status;
        x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;
        	RETURN;

    END;

    END IF;
    -- baroy - end
    -- End of IF condition #101 - Skipping header level validations

--  END Header processing block
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : WORK_ORDER MAIN Routine compelted with status of '||l_return_status) ; END IF ;

    IF NVL(l_return_status,'S') <> 'S'
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

--Added to find if workorder is firm or not
  IF(l_wip_entity_id IS NULL) THEN     --get wip_entity_id from workorder record as it is defaulted while creating
     l_wip_entity_id:= l_eam_wo_rec.wip_entity_id;
  END IF;

   SELECT firm_planned_flag
   INTO l_firm_planned_flag
   FROM WIP_DISCRETE_JOBS
   WHERE wip_entity_id = l_wip_entity_id;

   IF(l_firm_planned_flag=1) OR (nvl(l_eam_wo_rec.ds_scheduled_flag,'N')='Y')THEN
	--if firm set the scheduled flag as firm
       x_schedule_wo := G_FIRM_WORKORDER;

       IF l_eam_res_usage_tbl.count > 0 THEN
         x_bottomup_scheduled := G_UPDATE_RES_USAGE;
       END IF;

   ELSE
       x_bottomup_scheduled := G_NON_FIRM_WORKORDER;
   END IF;


    -- Process operations that are orphans but are indirect children of this header

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling WO_OPERATIONS from WORK_ORDER') ; END IF ;

        l_out_eam_wo_rec            := l_eam_wo_rec;
        l_out_eam_op_tbl            := l_eam_op_tbl;
        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Checking for standard operation from WORK_ORDER') ; END IF ;

	if (l_eam_wo_rec.asset_activity_id IS NOT NULL and
		(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
		or
		l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE and
		((l_eam_wo_rec.asset_activity_id <> l_old_eam_wo_rec.asset_activity_id) or l_old_eam_wo_rec.asset_activity_id is null)
		))
		then
			null ;
	else

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Exploding standard operation from WORK_ORDER') ; END IF ;

	-- Need to explode standard operations

		IF l_eam_op_tbl.COUNT > 0 THEN
			FOR J IN l_eam_op_tbl.FIRST..l_eam_op_tbl.LAST LOOP
				IF l_eam_op_tbl(J).standard_operation_id IS NOT NULL THEN
					declare

						CURSOR resOP IS
							select
							 l_eam_op_tbl(J).wip_entity_id,
							 l_eam_op_tbl(J).operation_seq_num,
							 bsor.resource_seq_num,
							 bso.organization_id,
							 bsor.LAST_UPDATE_DATE,
							 bsor.LAST_UPDATED_BY,
							 bsor.CREATION_DATE,
							 bsor.CREATED_BY,
							 bsor.LAST_UPDATE_LOGIN,
							 bsor.REQUEST_ID,
							 bsor.PROGRAM_APPLICATION_ID,
							 bsor.PROGRAM_ID,
							 bsor.PROGRAM_UPDATE_DATE,
							 bsor.RESOURCE_ID,
							 br.unit_of_measure,
							 bsor.BASIS_TYPE,
							 bsor.USAGE_RATE_OR_AMOUNT,
							 bsor.ACTIVITY_ID,
							 bsor.SCHEDULE_FLAG,
							 bsor.ASSIGNED_UNITS,
							 DECODE(bsor.autocharge_type,1,2,4,3,2,2,3,3,2) autocharge_type,
							 bsor.STANDARD_RATE_FLAG,
							 0 APPLIED_RESOURCE_UNITS,
							 0 APPLIED_RESOURCE_VALUE,
							 nvl(l_eam_op_tbl(J).start_date,sysdate) start_date,
							 nvl(l_eam_op_tbl(J).completion_date,sysdate) completion_date,
							 bsor.ATTRIBUTE_CATEGORY,
							 bsor.ATTRIBUTE1,
							 bsor.ATTRIBUTE2,
							 bsor.ATTRIBUTE3,
							 bsor.ATTRIBUTE4,
							 bsor.ATTRIBUTE5,
							 bsor.ATTRIBUTE6,
							 bsor.ATTRIBUTE7,
							 bsor.ATTRIBUTE8,
							 bsor.ATTRIBUTE9,
							 bsor.ATTRIBUTE10,
							 bsor.ATTRIBUTE11,
							 bsor.ATTRIBUTE12,
							 bsor.ATTRIBUTE13,
							 bsor.ATTRIBUTE14,
							 bsor.ATTRIBUTE15,
							 bso.DEPARTMENT_ID,
							 decode(bsor.SCHEDULE_FLAG,2,null,bsor.resource_seq_num)  ,
							 bsor.SUBSTITUTE_GROUP_NUM
							 from bom_standard_operations bso,
							      bom_std_op_resources bsor,
							      bom_resources br
							 where bso.standard_operation_id = bsor.standard_operation_id
							 and br.resource_id = bsor.resource_id
							 and bso.standard_operation_id = l_eam_op_tbl(J).standard_operation_id
							 and bso.organization_id = l_eam_op_tbl(J).organization_id;

							l_res_cnt NUMBER ;
							begin

								l_res_cnt:= l_eam_res_tbl.COUNT;

								  FOR resrec IN resOP LOOP

									l_res_cnt:=l_res_cnt+1; --counter for resources
									 l_eam_res_tbl(l_res_cnt).BATCH_ID			:= l_eam_op_tbl(J).BATCH_ID;
									 l_eam_res_tbl(l_res_cnt).HEADER_ID			:= l_eam_op_tbl(J).HEADER_ID;
									 l_eam_res_tbl(l_res_cnt).WIP_ENTITY_ID			:= l_eam_op_tbl(J).WIP_ENTITY_ID;
									 l_eam_res_tbl(l_res_cnt).ORGANIZATION_ID		:= l_eam_op_tbl(J).ORGANIZATION_ID;
									 l_eam_res_tbl(l_res_cnt).OPERATION_SEQ_NUM		:= l_eam_op_tbl(J).OPERATION_SEQ_NUM;
									 l_eam_res_tbl(l_res_cnt).DEPARTMENT_ID			:= resrec.DEPARTMENT_ID;
									 l_eam_res_tbl(l_res_cnt).RESOURCE_SEQ_NUM		:= resrec.RESOURCE_SEQ_NUM;
									 l_eam_res_tbl(l_res_cnt).RESOURCE_ID 			:= resrec.RESOURCE_ID;
									 l_eam_res_tbl(l_res_cnt).UOM_CODE 			:= resrec.UNIT_OF_MEASURE;
									 l_eam_res_tbl(l_res_cnt).BASIS_TYPE 			:= resrec.BASIS_TYPE;
									 l_eam_res_tbl(l_res_cnt).USAGE_RATE_OR_AMOUNT		:= resrec.USAGE_RATE_OR_AMOUNT;
									 l_eam_res_tbl(l_res_cnt).ACTIVITY_ID 			:= resrec.ACTIVITY_ID;
									 l_eam_res_tbl(l_res_cnt).SCHEDULED_FLAG		:= resrec.SCHEDULE_FLAG;
									 l_eam_res_tbl(l_res_cnt).ASSIGNED_UNITS 		:= resrec.ASSIGNED_UNITS;
									 l_eam_res_tbl(l_res_cnt).AUTOCHARGE_TYPE 		:= resrec.AUTOCHARGE_TYPE;
									 l_eam_res_tbl(l_res_cnt).STANDARD_RATE_FLAG		:= resrec.STANDARD_RATE_FLAG;
									 l_eam_res_tbl(l_res_cnt).APPLIED_RESOURCE_UNITS	:= resrec.APPLIED_RESOURCE_UNITS;
									 l_eam_res_tbl(l_res_cnt).APPLIED_RESOURCE_VALUE	:= resrec.APPLIED_RESOURCE_VALUE;
									 l_eam_res_tbl(l_res_cnt).START_DATE			:= resrec.START_DATE;
									 l_eam_res_tbl(l_res_cnt).COMPLETION_DATE 		:= resrec.COMPLETION_DATE;
									-- l_eam_res_tbl(l_res_cnt).SCHEDULE_SEQ_NUM 		:= resrec.SCHEDULE_SEQ_NUM;
									 l_eam_res_tbl(l_res_cnt).SUBSTITUTE_GROUP_NUM		:= resrec.SUBSTITUTE_GROUP_NUM;
									-- l_eam_res_tbl(l_res_cnt).REPLACEMENT_GROUP_NUM		:= resrec.REPLACEMENT_GROUP_NUM;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE_CATEGORY		:= resrec.ATTRIBUTE_CATEGORY;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE1			:= resrec.ATTRIBUTE1;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE2 			:= resrec.ATTRIBUTE2 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE3 			:= resrec.ATTRIBUTE3 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE4 			:= resrec.ATTRIBUTE4 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE5 			:= resrec.ATTRIBUTE5 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE6 			:= resrec.ATTRIBUTE6 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE7			:= resrec.ATTRIBUTE7 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE8 			:= resrec.ATTRIBUTE8 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE9 			:= resrec.ATTRIBUTE9 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE10			:= resrec.ATTRIBUTE10 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE11			:= resrec.ATTRIBUTE11 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE12			:= resrec.ATTRIBUTE12 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE13			:= resrec.ATTRIBUTE13 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE14			:= resrec.ATTRIBUTE14	;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE15			:= resrec.ATTRIBUTE15	;
									 l_eam_res_tbl(l_res_cnt).RETURN_STATUS 		:= l_eam_op_tbl(J).RETURN_STATUS ;
									 l_eam_res_tbl(l_res_cnt).TRANSACTION_TYPE 		:= l_eam_op_tbl(J).TRANSACTION_TYPE ;
								END LOOP;
							END;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Completed Exploding standard operation from WORK_ORDER') ; END IF ;

			--Non Standard Operation
				else  --if  l_eam_op_tbl(J).standard_operation_id IS NULL THEN
					declare

						CURSOR nonStdResOP IS
							select
							 l_eam_op_tbl(J).wip_entity_id,
							 l_eam_op_tbl(J).operation_seq_num,
							 wor.resource_seq_num,
							 wo.organization_id,
							 wor.LAST_UPDATE_DATE,
							 wor.LAST_UPDATED_BY,
							 wor.CREATION_DATE,
							 wor.CREATED_BY,
							 wor.LAST_UPDATE_LOGIN,
							 wor.REQUEST_ID,
							 wor.PROGRAM_APPLICATION_ID,
							 wor.PROGRAM_ID,
							 wor.PROGRAM_UPDATE_DATE,
							 wor.RESOURCE_ID,
							 br.unit_of_measure,
							 wor.BASIS_TYPE,
							 wor.USAGE_RATE_OR_AMOUNT,
							 wor.ACTIVITY_ID,
							 wor.SCHEDULED_FLAG,
							 wor.ASSIGNED_UNITS,
							 DECODE(wor.autocharge_type,1,2,4,3,2,2,3,3,2) autocharge_type,
							 wor.STANDARD_RATE_FLAG,
							 0 APPLIED_RESOURCE_UNITS,
							 0 APPLIED_RESOURCE_VALUE,
							 nvl(l_eam_op_tbl(J).start_date,sysdate) start_date,
							 nvl(l_eam_op_tbl(J).completion_date,sysdate) completion_date,
							 wor.ATTRIBUTE_CATEGORY,
							 wor.ATTRIBUTE1,
							 wor.ATTRIBUTE2,
							 wor.ATTRIBUTE3,
							 wor.ATTRIBUTE4,
							 wor.ATTRIBUTE5,
							 wor.ATTRIBUTE6,
							 wor.ATTRIBUTE7,
							 wor.ATTRIBUTE8,
							 wor.ATTRIBUTE9,
							 wor.ATTRIBUTE10,
							 wor.ATTRIBUTE11,
							 wor.ATTRIBUTE12,
							 wor.ATTRIBUTE13,
							 wor.ATTRIBUTE14,
							 wor.ATTRIBUTE15,
							 wo.DEPARTMENT_ID,
							 decode(wor.SCHEDULED_FLAG,2,null,wor.resource_seq_num)  ,
							 wor.SUBSTITUTE_GROUP_NUM
							 from wip_operations wo,
							      wip_OPERATION_resources wor,
							      bom_resources br
							 where wo.OPERATION_SEQ_NUM  = wor.OPERATION_SEQ_NUM
							 and br.resource_id = wor.resource_id
							 AND wo.wip_entity_id = wor.wip_entity_id
							 and wo.OPERATION_SEQ_NUM  = l_eam_op_tbl(J).OPERATION_SEQ_NUM
							 and wo.wip_entity_id = l_eam_op_tbl(J).wip_entity_id
							 and wo.organization_id = l_eam_op_tbl(J).organization_id;

							l_res_cnt NUMBER ;
							begin

								l_res_cnt:= l_eam_res_tbl.COUNT;

								  FOR resrec IN nonStdResOP LOOP

									l_res_cnt:=l_res_cnt+1; --counter for resources
									 l_eam_res_tbl(l_res_cnt).BATCH_ID			:= l_eam_op_tbl(J).BATCH_ID;
									 l_eam_res_tbl(l_res_cnt).HEADER_ID			:= l_eam_op_tbl(J).HEADER_ID;
									 l_eam_res_tbl(l_res_cnt).WIP_ENTITY_ID			:= l_eam_op_tbl(J).WIP_ENTITY_ID;
									 l_eam_res_tbl(l_res_cnt).ORGANIZATION_ID		:= l_eam_op_tbl(J).ORGANIZATION_ID;
									 l_eam_res_tbl(l_res_cnt).OPERATION_SEQ_NUM		:= l_eam_op_tbl(J).OPERATION_SEQ_NUM;
									 l_eam_res_tbl(l_res_cnt).DEPARTMENT_ID			:= resrec.DEPARTMENT_ID;
									 l_eam_res_tbl(l_res_cnt).RESOURCE_SEQ_NUM		:= resrec.RESOURCE_SEQ_NUM;
									 l_eam_res_tbl(l_res_cnt).RESOURCE_ID 			:= resrec.RESOURCE_ID;
									 l_eam_res_tbl(l_res_cnt).UOM_CODE 			:= resrec.UNIT_OF_MEASURE;
									 l_eam_res_tbl(l_res_cnt).BASIS_TYPE 			:= resrec.BASIS_TYPE;
									 l_eam_res_tbl(l_res_cnt).USAGE_RATE_OR_AMOUNT		:= resrec.USAGE_RATE_OR_AMOUNT;
									 l_eam_res_tbl(l_res_cnt).ACTIVITY_ID 			:= resrec.ACTIVITY_ID;
									 l_eam_res_tbl(l_res_cnt).SCHEDULED_FLAG		:= resrec.SCHEDULED_FLAG;
									 l_eam_res_tbl(l_res_cnt).ASSIGNED_UNITS 		:= resrec.ASSIGNED_UNITS;
									 l_eam_res_tbl(l_res_cnt).AUTOCHARGE_TYPE 		:= resrec.AUTOCHARGE_TYPE;
									 l_eam_res_tbl(l_res_cnt).STANDARD_RATE_FLAG		:= resrec.STANDARD_RATE_FLAG;
									 l_eam_res_tbl(l_res_cnt).APPLIED_RESOURCE_UNITS	:= resrec.APPLIED_RESOURCE_UNITS;
									 l_eam_res_tbl(l_res_cnt).APPLIED_RESOURCE_VALUE	:= resrec.APPLIED_RESOURCE_VALUE;
									 l_eam_res_tbl(l_res_cnt).START_DATE			:= resrec.START_DATE;
									 l_eam_res_tbl(l_res_cnt).COMPLETION_DATE 		:= resrec.COMPLETION_DATE;
									-- l_eam_res_tbl(l_res_cnt).SCHEDULE_SEQ_NUM 		:= resrec.SCHEDULE_SEQ_NUM;
									 l_eam_res_tbl(l_res_cnt).SUBSTITUTE_GROUP_NUM		:= resrec.SUBSTITUTE_GROUP_NUM;
									-- l_eam_res_tbl(l_res_cnt).REPLACEMENT_GROUP_NUM		:= resrec.REPLACEMENT_GROUP_NUM;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE_CATEGORY		:= resrec.ATTRIBUTE_CATEGORY;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE1			:= resrec.ATTRIBUTE1;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE2 			:= resrec.ATTRIBUTE2 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE3 			:= resrec.ATTRIBUTE3 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE4 			:= resrec.ATTRIBUTE4 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE5 			:= resrec.ATTRIBUTE5 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE6 			:= resrec.ATTRIBUTE6 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE7			:= resrec.ATTRIBUTE7 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE8 			:= resrec.ATTRIBUTE8 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE9 			:= resrec.ATTRIBUTE9 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE10			:= resrec.ATTRIBUTE10 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE11			:= resrec.ATTRIBUTE11 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE12			:= resrec.ATTRIBUTE12 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE13			:= resrec.ATTRIBUTE13 ;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE14			:= resrec.ATTRIBUTE14	;
									 l_eam_res_tbl(l_res_cnt).ATTRIBUTE15			:= resrec.ATTRIBUTE15	;
									 l_eam_res_tbl(l_res_cnt).RETURN_STATUS 		:= l_eam_op_tbl(J).RETURN_STATUS ;
									 l_eam_res_tbl(l_res_cnt).TRANSACTION_TYPE 		:= l_eam_op_tbl(J).TRANSACTION_TYPE ;
								END LOOP;
				     END; --end for delcare begin end
				     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Completed Exploding manual operation from WORK_ORDER') ; END IF ;


				END IF;    --non-standard oper



			END LOOP;     --operation table loop
		END IF;                               --operation tabe count check
	END IF;

        l_out_eam_res_tbl           := l_eam_res_tbl;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling WO_OPERATIONS from WORK_ORDER') ; END IF ;

        WO_OPERATIONS
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_wo_rec.organization_id
        ,  p_eam_op_tbl                    =>  l_eam_op_tbl
        ,  p_eam_op_network_tbl            =>  l_eam_op_network_tbl
        ,  p_eam_res_tbl                   =>  l_eam_res_tbl
        ,  p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl               =>  l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl               =>  l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl               =>  l_eam_direct_items_tbl
        ,  x_eam_op_tbl                    =>  l_out_eam_op_tbl
        ,  x_eam_op_network_tbl            =>  l_out_eam_op_network_tbl
        ,  x_eam_res_tbl                   =>  l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl              =>  l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl               =>  l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl               =>  l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl               =>  l_out_eam_direct_items_tbl
	,  x_schedule_wo                   =>  x_schedule_wo
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
	,  x_material_shortage		   => x_material_shortage
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_wo_rec            := l_out_eam_wo_rec;
        l_eam_op_tbl            := l_out_eam_op_tbl;
        l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
        l_eam_res_tbl           := l_out_eam_res_tbl;
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
        l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : WO_OPERATIONS compelted with status of '||l_return_status) ; END IF ;

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


        -- Process Resources

        IF l_eam_res_tbl.count <> 0 then

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling OPERATION_RESOURCES from WORK_ORDER') ; END IF ;

        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;

        OPERATION_RESOURCES
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_wo_rec.organization_id
        ,  p_eam_res_tbl                   =>  l_eam_res_tbl
        ,  p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
        ,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
        ,  x_eam_res_tbl                   =>  l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl              =>  l_out_eam_res_inst_tbl
        ,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
	,  x_schedule_wo                   =>  x_schedule_wo
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_res_tbl           := l_out_eam_res_tbl;
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;


    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;



IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : OPERATION_RESOURCE completed with status of '||l_return_status) ; END IF ;

        END IF;

        -- Process Material Requirements

        IF l_eam_mat_req_tbl.count <> 0 then

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling MATERIAL_REQUIREMENTS from WORK_ORDER') ; END IF ;

        l_out_eam_mat_req_tbl := l_eam_mat_req_tbl;

        MATERIAL_REQUIREMENTS
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_wo_rec.organization_id
        ,  p_eam_mat_req_tbl               =>  l_eam_mat_req_tbl
	,  x_material_shortage		   =>  x_material_shortage
        ,  x_eam_mat_req_tbl               =>  l_out_eam_mat_req_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_mat_req_tbl := l_out_eam_mat_req_tbl;


    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : MATERIAL_REQUIREMENTS completed with status of '||l_return_status) ; END IF ;

        END IF;


        -- Process Direct Items

        IF l_eam_direct_items_tbl.count <> 0 then

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling DIRECT ITEMS from WORK_ORDER') ; END IF ;

        l_out_eam_direct_items_tbl := l_eam_direct_items_tbl;

        DIRECT_ITEMS
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_wo_rec.organization_id
        ,  p_eam_direct_items_tbl          =>  l_eam_direct_items_tbl
	,  x_material_shortage		   =>  x_material_shortage
        ,  x_eam_direct_items_tbl          =>  l_out_eam_direct_items_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_direct_items_tbl := l_out_eam_direct_items_tbl;


    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : DIRECT_ITEMS completed with status of '||l_return_status) ; END IF ;

        END IF;


        -- Process Operation Networks

        IF l_eam_op_network_tbl.count <> 0 then

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling OPERATION_NETWORKS from WORK_ORDER') ; END IF ;

        l_out_eam_op_network_tbl := l_eam_op_network_tbl;

        OPERATION_NETWORKS
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_wo_rec.organization_id
        ,  p_eam_op_network_tbl            =>  l_eam_op_network_tbl
        ,  x_eam_op_network_tbl            =>  l_out_eam_op_network_tbl
	,  x_schedule_wo                   =>  x_schedule_wo
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        );

        l_eam_op_network_tbl := l_out_eam_op_network_tbl;

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : OPERATION_NETWORKS completed with status of '||l_return_status) ; END IF ;

        END IF;


    -- Process resource instance that are orphans
      IF l_eam_res_inst_tbl.count <> 0 then

        l_out_eam_res_inst_tbl := l_eam_res_inst_tbl;

        RESOURCE_INSTANCES
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_organization_id               =>  l_eam_wo_rec.organization_id
        ,  p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
        ,  x_eam_res_inst_tbl              =>  l_out_eam_res_inst_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
	,  x_schedule_wo		   =>  x_schedule_wo
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
        );

        l_eam_res_inst_tbl := l_out_eam_res_inst_tbl;


    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    END IF;


    -- Process substitue resource that are orphans
    IF l_eam_sub_res_tbl.count <> 0 then

        l_out_eam_sub_res_tbl   := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl := l_eam_res_usage_tbl;

      /*  SUB_RESOURCES
        (  p_validation_level              =>  p_validation_level
        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
        ,  p_eam_sub_res_tbl               =>  l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
	,  x_bottomup_scheduled		   =>  x_bottomup_scheduled
        ,  x_eam_sub_res_tbl               =>  l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
        ,  x_mesg_token_tbl                =>  l_mesg_token_tbl
        ,  x_return_status                 =>  l_return_status
        ); */

        l_eam_sub_res_tbl   := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl := l_out_eam_res_usage_tbl;

    IF l_return_status <> 'S'
    THEN
        l_bo_return_status := l_return_status;
    END IF;

    END IF;

BEGIN   --begin of processing workorder entity
    IF(nvl(l_bo_return_status,'S') = 'S'    --if successful
       AND l_eam_wo_rec.transaction_type IS NOT NULL) THEN    --process workorder record

	   -- baroy - If wo rec is null, then don't do status change
           -- If condition #100
           IF (l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE OR
               (l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE and
                l_eam_wo_rec.status_type <> l_old_eam_wo_rec.status_type
               )
              ) then
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling Change_Status API') ; END IF ;

              -- Defaulting the date_released only when workflow is approved /no workflow and work order is actually released.
	      --Removed following code from EAMVWODB.pls and added it here

               IF ( (l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE and
                      l_eam_wo_rec.status_type = 3 ) OR
                     (l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE and
                      l_old_eam_wo_rec.status_type <> 3 and l_eam_wo_rec.status_type = 3)
                   )
                THEN

		                      IF(l_eam_wo_rec.date_released IS NULL OR
                                                        l_eam_wo_rec.date_released = FND_API.G_MISS_DATE) THEN

									     /*Bug#4425025 - set date_released to greatest of min open period start date
									      *and scheduled start date if scheduled start date is in past*/

									     IF (l_eam_wo_rec.scheduled_start_date < sysdate)
									     THEN
																	       select nvl(min(period_start_date),l_eam_wo_rec.scheduled_start_date)
																	       into l_min_open_period_date
																	       from org_acct_periods
																	       where organization_id=l_eam_wo_rec.organization_id
																		 and open_flag = 'Y'
																		 and period_close_date is null;

																	       l_eam_wo_rec.date_released := greatest (l_min_open_period_date,l_eam_wo_rec.scheduled_start_date);
									     ELSE
																			l_eam_wo_rec.date_released := sysdate;
									   END IF;
					 END IF; --end of check for date_released is null

		                        UPDATE WIP_DISCRETE_JOBS
                                                SET date_released = l_eam_wo_rec.date_released,
                                                         last_update_date = SYSDATE,
                                                         last_updated_by = FND_GLOBAL.User_Id,
                                                         last_update_login = FND_GLOBAL.Login_Id
                                                WHERE wip_entity_id=l_eam_wo_rec.wip_entity_id
                                               AND organization_id=l_eam_wo_rec.organization_id;

                END IF;  --end of check for work order being released

			      EAM_WO_CHANGE_STATUS_PVT.Change_Status
			      (  p_api_version            => 1.0
			      ,  p_init_msg_list          => null
			      ,  p_commit                 => null
			      ,  p_validation_level       => null
			      ,  p_wip_entity_id          => l_eam_wo_rec.wip_entity_id
			      ,  p_organization_id        => l_eam_wo_rec.organization_id
			      ,  p_to_status_type         => l_eam_wo_rec.status_type
			      ,  p_user_id                => l_eam_wo_rec.user_id
			      ,  p_responsibility_id      => l_eam_wo_rec.responsibility_id
			      ,  p_date_released          => l_eam_wo_rec.date_released
			      ,   p_report_type              =>    l_eam_wo_rec.report_type
                              ,   p_actual_close_date   =>   l_eam_wo_rec.actual_close_date
                              , p_submission_date      =>    l_eam_wo_rec.submission_date
 			      ,  p_work_order_mode        => l_eam_wo_rec.transaction_type
			      ,  x_request_id             => l_request_id
			      ,  x_return_status          => l_return_status
			      ,  x_msg_count              => l_error_text
			      ,  x_msg_data               => l_other_message
			      ,  x_Mesg_Token_Tbl         => l_mesg_token_tbl
			      );

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Status Change WO completed with status ' || l_return_status) ; END IF ;
				IF NVL(l_return_status, 'S') <> 'S' THEN
				       l_return_status := FND_API.G_RET_STS_ERROR;
				       RAISE G_ERR_STATUS_CHANGE;

				END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Status Change WO completed with status ' || l_return_status) ; END IF ;


	       END IF;
	       -- baroy - End if for condition #100



	--fix for 3572280.populate the released_quantity in the materials records from the required_quantity
	BEGIN
	   IF(
	     (l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_CREATE and
             l_eam_wo_rec.status_type = 3)
	     OR
	     (l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_UPDATE and
	      l_eam_wo_rec.status_type = 3 and
	      ((l_old_eam_wo_rec.date_released is null and l_old_eam_wo_rec.status_type IN (17,6,7)) OR (l_old_eam_wo_rec.status_type=1)))
	     )
	     THEN
			update wip_requirement_operations
			set released_quantity=required_quantity,
			       last_update_date = SYSDATE,
			       last_updated_by = FND_GLOBAL.User_Id,
			       last_update_login = FND_GLOBAL.Login_Id
			where wip_entity_id=l_eam_wo_rec.wip_entity_id
			and organization_id=l_eam_wo_rec.organization_id
			and required_quantity > 0;

           END IF;
	  EXCEPTION
		     WHEN OTHERS THEN
			l_return_status:='U';
			RAISE POPULATE_RELEASE_ERR;
          END;   --end of block for populating released_quantity

	-- 3521842
	-- If the Auto firm on release flag = Y or user manually firms a flag while creating a Work Order
	-- then if activity is associated then call schedular

        --if activity is added/updated/deleted for firm/non-firm workorder call scheduler
	if (x_schedule_wo <> G_SCHEDULE_WO and l_eam_wo_rec.asset_activity_id IS NOT NULL and
		(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
		or
		l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE and
		((l_eam_wo_rec.asset_activity_id <> l_old_eam_wo_rec.asset_activity_id) or l_old_eam_wo_rec.asset_activity_id is null)
		))
		then

		x_schedule_wo := G_SCHEDULE_WO;
	end if;

	-- if activity is deleted then also scheduler should get call
	if (x_schedule_wo <> G_SCHEDULE_WO and  l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE
		 and l_old_eam_wo_rec.asset_activity_id is not null
		 and (l_eam_wo_rec.asset_activity_id is null or l_eam_wo_rec.asset_activity_id = FND_API.G_MISS_NUM)) then
		 x_schedule_wo := G_SCHEDULE_WO;
	end if;



        IF (l_request_id is null and x_bottomup_scheduled=G_NOT_BU_SCHEDULE_WO) then  --if non-firm and not yet set to schedule

			   IF(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
				OR
				(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE
--				  AND l_eam_wo_rec.status_type <> 6    --status not equal to on-hold
				  AND
				  ((l_eam_wo_rec.requested_start_date IS NULL AND l_old_eam_wo_rec.requested_start_date IS NOT NULL) --changing from forward to backward sched
				   OR (l_eam_wo_rec.requested_start_date IS NOT NULL AND l_old_eam_wo_rec.requested_start_date IS NULL) --changing from b/w to f/w sched
				   OR l_eam_wo_rec.requested_start_date <> l_old_eam_wo_rec.requested_start_date  --changing dates
				   OR l_eam_wo_rec.due_date <> l_old_eam_wo_rec.due_date
				   OR l_eam_wo_rec.scheduled_start_date <> l_old_eam_wo_rec.scheduled_start_date
				   OR l_eam_wo_rec.scheduled_completion_date <> l_old_eam_wo_rec.scheduled_completion_date
				   OR (l_eam_wo_rec.firm_planned_flag=1 AND l_old_eam_wo_rec.firm_planned_flag=2 ))  --changing from firm to non-firm
				)) THEN
				     x_bottomup_scheduled := G_BU_SCHEDULE_WO;
			    END IF;  --end of check for conditons to call bottom up scheduler

         END IF;


	IF (l_request_id is null and x_schedule_wo=G_NOT_SCHEDULE_WO) then  --if non-firm and not yet set to schedule
            IF(l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_UPDATE AND
	    --if changing status to cancelled,complete-no-chrg,close do not call scheduler
	        (l_eam_wo_rec.status_type IN (7,5,12,14,15)) AND (l_old_eam_wo_rec.status_type <> l_eam_wo_rec.status_type)) THEN
                        NULL;
	    ELSIF(l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_UPDATE AND
	     --if changing status from on-hold,cancelled,complete-no-chrg,close to something else .call scheduler
	        (l_old_eam_wo_rec.status_type IN (6,7,5,12,14,15)) AND (l_eam_wo_rec.status_type NOT IN (6,7,5,12,14,15))) THEN
		   x_schedule_wo := G_SCHEDULE_WO;
            ELSE
			   IF(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
				OR
				(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_UPDATE
				  --AND l_eam_wo_rec.status_type <> 6    --status not equal to on-hold
				  AND
				  ((l_eam_wo_rec.requested_start_date IS NULL AND l_old_eam_wo_rec.requested_start_date IS NOT NULL) --changing from forward to backward sched
				   OR (l_eam_wo_rec.requested_start_date IS NOT NULL AND l_old_eam_wo_rec.requested_start_date IS NULL) --changing from b/w to f/w sched
				   OR l_eam_wo_rec.requested_start_date <> l_old_eam_wo_rec.requested_start_date  --changing dates
				   OR l_eam_wo_rec.due_date <> l_old_eam_wo_rec.due_date
				   OR l_eam_wo_rec.scheduled_start_date <> l_old_eam_wo_rec.scheduled_start_date
				   OR l_eam_wo_rec.scheduled_completion_date <> l_old_eam_wo_rec.scheduled_completion_date
				   OR (l_eam_wo_rec.firm_planned_flag=2 AND l_old_eam_wo_rec.firm_planned_flag=1 ))  --changing from firm to non-firm
				)) THEN
				     x_schedule_wo := G_SCHEDULE_WO;   --3521842
			    END IF;  --end of check for conditons to call scheduler


              END IF;
         END IF;

     /* call for cost estimator to estimate work orders created with activity */

        IF ( (l_eam_wo_rec.asset_activity_id IS NOT NULL and l_eam_wo_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE) OR
	     (l_asset_changed='Y' and l_already_estimated = 'Y') ) THEN --ER 8374077

        /* Verify if there are departments, before launching cost estimation */

	   Begin
        select 1
		into l_count
		from wip_operations
		where wip_entity_id =  l_eam_wo_rec.wip_entity_id
		and department_id is null;
       Exception
         When no_data_found then
            l_count := 1;
       End;

		if l_count >=1 then
		   if (l_eam_wo_rec.owning_department is null) then
		   		select count(*)
		   		into l_count
		   		from wip_eam_parameters
		   		where organization_id = l_eam_wo_rec.organization_id
		   		and default_department_id is null;
		   	else
		   	   l_count := 0;
		    end if;
		end if;

		if l_count >= 1 then
				EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : No department on Work Order or at organization level. Skipping Estimation ') ;
		else



                                --Set the workorder's estimation status to 'Running' and call online cost estimation API CSTPECEP.Estimate_WorkOrder_Grp
                                                UPDATE WIP_DISCRETE_JOBS
                                                SET estimation_status = 2,
                                                         last_update_date = SYSDATE,
                                                         last_updated_by = FND_GLOBAL.User_Id,
                                                         last_update_login = FND_GLOBAL.Login_Id
                                                WHERE wip_entity_id=l_eam_wo_rec.wip_entity_id
                                               AND organization_id=l_eam_wo_rec.organization_id;

                                          BEGIN
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling the Estimate_Workorder_Grp procedure ...') ; END IF ;
                                               CSTPECEP.Estimate_WorkOrder_Grp(
                                                                 p_api_version => 1.0,
                                                                 p_init_msg_list => fnd_api.g_false,
                                                                 p_commit  =>  fnd_api.g_false,
                                                                 p_validation_level  => fnd_api.g_valid_level_full,
                                                                 p_wip_entity_id => l_eam_wo_rec.wip_entity_id,
                                                                 p_organization_id => l_eam_wo_rec.organization_id,
                                                                 x_return_status      => l_return_status,
                                                                 x_msg_data           => l_err_text,
                                                                 x_msg_count          => l_msg_count );
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Estimate_Workorder_Grp procedure completed with status '||l_return_status) ; END IF ;

                                                  IF (l_return_status <> 'S') THEN
                                                         l_bo_return_status := l_return_status;
                                                  END IF;
                                      EXCEPTION
                                             WHEN OTHERS THEN
                                                    l_bo_return_status := FND_API.G_RET_STS_ERROR;
                                         END;
        END IF;--end of department check
        END IF;--end of check for activity present


	--Raise workflow events
	IF(l_workflow_enabled = 'Y') THEN        --if workflow is enabled
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Calling the Raise_Workflow_Events procedure ...') ; END IF ;
				Raise_Workflow_Events
				(
				     p_api_version   =>   1.0,
				     p_validation_level => p_validation_level,
				     p_eam_wo_rec => l_eam_wo_rec,
				     p_old_eam_wo_rec => l_old_eam_wo_rec,
				     p_approval_required   =>  l_approval_required,
				     p_new_system_status     =>    l_new_system_status,
				     p_workflow_name    =>   l_pending_workflow_name,
				     p_workflow_process   =>   l_pending_workflow_process,
				     x_return_status => l_return_status,
				     x_mesg_token_tbl => l_mesg_token_tbl
				);

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER : Raise_Workflow_Events procedure completed with status '||l_return_status) ; END IF ;
				IF(l_return_status <> 'S') THEN
					l_bo_return_status := l_return_status;
				END IF;
	END IF;  --end of check for workflow enabled


    END IF;  --end of check for l_bo_return_status and 'S'

IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.WORK_ORDER :  End================================================'); END IF;


EXCEPTION
   WHEN POPULATE_RELEASE_ERR THEN

            l_token_tbl(1).token_name  := 'WORKORDER';
            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_POPULATE_REL_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

         l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
         l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
         l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
         l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        x_return_status                := l_return_status;
	x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;
	RETURN;

   WHEN G_ERR_STATUS_CHANGE THEN


            l_token_tbl(1).token_name  := 'Wip Entity Id';
            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WO_STATUS_CHG_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

         l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
         l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
         l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
         l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        x_return_status                := l_return_status;
	x_mesg_token_tbl               := l_mesg_token_tbl;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;
	RETURN;



END;   --end of block for processing workorder entity

    --  Load OUT parameters
        IF nvl(l_bo_return_status,'S') <> 'S' THEN
          x_return_status 	       := l_bo_return_status;
        END IF;

        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl         := l_eam_direct_items_tbl;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;



END WORK_ORDER;




    /********************************************************************
    * Procedure: Process_WO
    * Parameters IN:
    *         EAM Work Order column record
    *         Operation column table
    *         Operation Networks column Table
    *         Resource column Table
    *         Substitute Resource column table
    *         Resource Usage column table
    *         Material Requirements column table
    * Parameters OUT:
    *         EAM Work Order column record
    *         Operation column table
    *         Operation Networks column Table
    *         Resource column Table
    *         Substitute Resource column table
    *         Resource Usage column table
    *         Material Requirements column table
    * Purpose:
    *         This procedure is the driving procedure of the EAM
    *         business Obect. It will verify the integrity of the
    *         business object and will call the private API which
    *         further drive the business object to perform business
    *         logic validations.
    *********************************************************************/

PROCEDURE PROCESS_WO
         ( p_api_version_number      IN  NUMBER := 1.0
         , p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_eam_wo_rec              IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl         IN EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         )
IS
        l_api_version_number         CONSTANT NUMBER := 1.0;
        l_api_name                   CONSTANT VARCHAR2(30):= 'EAM_PROCESS_WO_PVT';
        l_err_text                   VARCHAR2(240);
        l_return_status              VARCHAR2(1);

        l_eam_return_status          VARCHAR2(1);

        l_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl                 EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl         EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl                EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl           EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl            EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl          EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl            EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_direct_items_tbl            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

        -- baroy - added for making the NOCOPY changes
        l_out_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl                 EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl         EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl                EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl           EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl            EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl          EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl            EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_direct_items_tbl            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
        l_out_mesg_token_tbl             EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;

        l_old_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_scheduled                      NUMBER;
		l_bottomup_scheduled             NUMBER;
        l_wip_entity_id                  NUMBER;
        l_organization_id                NUMBER;

        l_mesg_token_tbl             EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_token_tbl                  EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_other_message              VARCHAR2(2000);
        l_other_token_tbl            EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_msg_count                  NUMBER := 0;

        EXC_ERR_PVT_API_MAIN         EXCEPTION;
        CHECK_WO_DATES_ERR           EXCEPTION;
		CHECK_WO_RES_DATES_ERR	     EXCEPTION;
		CHECK_WO_NEGATIVE_DATES_ERR  EXCEPTION;
     	VALIDATE_NETWORK_ERR         EXCEPTION;
		OSP_REQ_ERR                  EXCEPTION;
		CHECK_OP_NETWORK_DATES_ERR   EXCEPTION;
		SCHEDULE_BOTTOM_UP_ERR	     EXCEPTION;
		UPDATE_RES_USAGE_BU_ERR      EXCEPTION;
		ALLOC_CREATION_ERR           EXCEPTION;


		l_msg_data					VARCHAR2(2000);
		x_shortage_exists			VARCHAR2(1);
        l_start_date                DATE;
        l_completion_date           DATE;
        l_error_text                NUMBER;

		l_prior_op_no		       NUMBER;
		l_next_op_no		       NUMBER;
		l_wo_relationship_exc_tbl    EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;
		l_material_shortage	    NUMBER;

		TYPE wkorder_op_tbl_type     is TABLE OF number INDEX BY BINARY_INTEGER;
        TYPE wkorder_op_dt_tbl_type  is TABLE OF DATE INDEX BY BINARY_INTEGER;

		l_wkorder_old_op_tbl	     wkorder_op_tbl_type;
		l_wkorder_old_op_dt_tbl      wkorder_op_dt_tbl_type;

		l_wkorder_new_op_tbl	     wkorder_op_tbl_type;
		l_wkorder_new_op_dt_tbl      wkorder_op_dt_tbl_type;

  		no_of_days NUMBER;
		l_wo_old_sch_start_date		DATE;
		l_wo_new_sch_start_date		DATE;
		l_emp_assignment		BOOLEAN;

		l_res_usage_tbl_index                NUMBER;
		-- changes for bug 9138126
        l_res_inst_usage_tbl_index           NUMBER;
        l_max_res_usg_compl_date             DATE;
        l_min_res_usg_start_date             DATE;
        -- end of changes bug 9138126
        l_woru_modified                 VARCHAR2(3);
		l_source_code                   VARCHAR2(10);

        CURSOR        get_opresource_csr( c_wip_entity_id NUMBER) IS
        SELECT    start_date,
                  completion_date,
                  operation_seq_num,
                  resource_seq_num
        FROM      wip_operation_resources
        WHERE      wip_entity_id = c_wip_entity_id;


BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_PROCESS_WO_PVT.PROCESS_WO : Start========================================================') ; END IF ;

		l_wkorder_old_op_tbl.delete;
		l_wkorder_old_op_dt_tbl.delete;

		l_wkorder_new_op_tbl.delete;
		l_wkorder_new_op_dt_tbl.delete;

        -- Initialize local variables

        l_eam_wo_rec            := p_eam_wo_rec;
        l_eam_op_tbl            := p_eam_op_tbl;
        l_eam_op_network_tbl    := p_eam_op_network_tbl;
        l_eam_res_tbl           := p_eam_res_tbl;
        l_eam_res_inst_tbl      := p_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := p_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := p_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := p_eam_mat_req_tbl;
        l_eam_direct_items_tbl  := p_eam_direct_items_tbl;


        -- Business Object Starts with a status of Success

        l_eam_return_status     := 'S';
        x_return_status         := FND_API.G_RET_STS_SUCCESS;


        -- baroy - query the old row for use in scheduling decisions later on
        -- in this procedure.
        IF l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE THEN
			  EAM_WO_UTILITY_PVT.Query_Row
			  ( p_wip_entity_id       => p_eam_wo_rec.wip_entity_id
			  , p_organization_id     => p_eam_wo_rec.organization_id
			  , x_eam_wo_rec          => l_old_eam_wo_rec
			  , x_Return_status       => l_return_status
			  );
        END IF;

       -- Find out the wip_entity_id and organization_id of this BO

		if l_eam_wo_rec.transaction_type is not null then
				NULL;    --find wip_entity_id later after processing workorder coz it is defaulted when creating workorder
		elsif l_eam_op_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_op_tbl(l_eam_op_tbl.first).wip_entity_id;
				l_organization_id := l_eam_op_tbl(l_eam_op_tbl.first).organization_id;
		elsif l_eam_op_network_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_op_network_tbl(l_eam_op_network_tbl.first).wip_entity_id;
				l_organization_id := l_eam_op_network_tbl(l_eam_op_network_tbl.first).organization_id;
		elsif l_eam_res_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_res_tbl(l_eam_res_tbl.first).wip_entity_id;
				l_organization_id := l_eam_res_tbl(l_eam_res_tbl.first).organization_id;
		elsif l_eam_mat_req_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_mat_req_tbl(l_eam_mat_req_tbl.first).wip_entity_id;
				l_organization_id := l_eam_mat_req_tbl(l_eam_mat_req_tbl.first).organization_id;
		elsif l_eam_direct_items_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_direct_items_tbl(l_eam_direct_items_tbl.first).wip_entity_id;
				l_organization_id := l_eam_direct_items_tbl(l_eam_direct_items_tbl.first).organization_id;
		elsif l_eam_res_inst_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_res_inst_tbl(l_eam_res_inst_tbl.first).wip_entity_id;
				l_organization_id := l_eam_res_inst_tbl(l_eam_res_inst_tbl.first).organization_id;
		elsif l_eam_sub_res_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_sub_res_tbl(l_eam_sub_res_tbl.first).wip_entity_id;
				l_organization_id := l_eam_sub_res_tbl(l_eam_sub_res_tbl.first).organization_id;
		elsif l_eam_res_usage_tbl.count <> 0 then
				l_wip_entity_id   := l_eam_res_usage_tbl(l_eam_res_usage_tbl.first).wip_entity_id;
				l_organization_id := l_eam_res_usage_tbl(l_eam_res_usage_tbl.first).organization_id;
		end if;


		if l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE then
				l_wip_entity_id   := l_eam_wo_rec.wip_entity_id;
				l_organization_id := l_eam_wo_rec.organization_id;
		end if;

		if l_eam_wo_rec.wip_entity_id is not  null and l_eam_wo_rec.organization_id is not null then
				l_wip_entity_id   := l_eam_wo_rec.wip_entity_id;
				l_organization_id := l_eam_wo_rec.organization_id;
		end if;

		IF l_wip_entity_id IS NOT NULL THEN
				select SCHEDULED_START_DATE into l_wo_old_sch_start_date
				from wip_discrete_jobs
				where wip_entity_id = l_wip_entity_id;
		END IF;

        -- Start with processing of the EAM Work Order Header


		l_out_eam_wo_rec            := l_eam_wo_rec;
		l_out_eam_op_tbl            := l_eam_op_tbl;
		l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
		l_out_eam_res_tbl           := l_eam_res_tbl;
		l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
		l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
		l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
		l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
		l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

		l_scheduled		:= G_NOT_SCHEDULE_WO;    --initialise to not calling scheduler
		l_bottomup_scheduled    := G_NOT_BU_SCHEDULE_WO;    --initialise for bottom up schedular

		begin
				select operation_seq_num,first_unit_start_date
				bulk collect into l_wkorder_old_op_tbl,l_wkorder_old_op_dt_tbl
				from wip_operations
				where  organization_id = l_organization_id
				and  wip_entity_id = l_wip_entity_id ;
		exception when others then
				null;
		end;

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_PROCESS_WO_PVT.PROCESS_WO : Calling the WORK_ORDER procedure...') ; END IF ;

		WORK_ORDER
				(  p_validation_level              =>  p_validation_level
				,  p_wip_entity_id                 =>  l_wip_entity_id
				,  p_eam_wo_rec                    =>  l_eam_wo_rec
				,  p_eam_op_tbl                    =>  l_eam_op_tbl
				,  p_eam_op_network_tbl            =>  l_eam_op_network_tbl
				,  p_eam_res_tbl                   =>  l_eam_res_tbl
				,  p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
				,  p_eam_sub_res_tbl               =>  l_eam_sub_res_tbl
				,  p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
				,  p_eam_mat_req_tbl               =>  l_eam_mat_req_tbl
				,  p_eam_direct_items_tbl          =>  l_eam_direct_items_tbl
				,  x_eam_wo_rec                    =>  l_out_eam_wo_rec
				,  x_eam_op_tbl                    =>  l_out_eam_op_tbl
				,  x_eam_op_network_tbl            =>  l_out_eam_op_network_tbl
				,  x_eam_res_tbl                   =>  l_out_eam_res_tbl
				,  x_eam_res_inst_tbl              =>  l_out_eam_res_inst_tbl
				,  x_eam_sub_res_tbl               =>  l_out_eam_sub_res_tbl
				,  x_eam_res_usage_tbl             =>  l_out_eam_res_usage_tbl
				,  x_eam_mat_req_tbl               =>  l_out_eam_mat_req_tbl
				,  x_eam_direct_items_tbl          =>  l_out_eam_direct_items_tbl
				,  x_schedule_wo                   =>  l_scheduled
				,  x_bottomup_scheduled            =>  l_bottomup_scheduled
				,  x_material_shortage		   =>  l_material_shortage
				,  x_mesg_token_tbl                =>  l_mesg_token_tbl
				,  x_return_status                 =>  l_return_status
		);

		l_eam_wo_rec            := l_out_eam_wo_rec;
		l_eam_op_tbl            := l_out_eam_op_tbl;
		l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
		l_eam_res_tbl           := l_out_eam_res_tbl;
		l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
		l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
		l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
		l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
		l_eam_direct_items_tbl       := l_out_eam_direct_items_tbl;

		IF NVL(l_return_status, 'S') = 'Q' THEN
			l_return_status := 'F';
			RAISE G_EXC_QUIT_IMPORT;

		ELSIF NVL(l_return_status, 'S') = 'U' THEN
			RAISE G_EXC_QUIT_IMPORT;

		ELSIF NVL(l_return_status, 'S') <> 'S' THEN
			l_eam_return_status := l_return_status;

		END IF;


		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : WORK_ORDER completed with status of '||l_eam_return_status) ; END IF ;

		if nvl(l_eam_return_status,'S') = 'S' then

				IF(l_eam_wo_rec.transaction_type IS NOT NULL) THEN    -- wip_entity_id will be defaulted when creating workorder
						l_wip_entity_id   := l_eam_wo_rec.wip_entity_id;
						l_organization_id := l_eam_wo_rec.organization_id;
				END IF;

				if l_eam_wo_rec.transaction_type is null then
						EAM_WO_UTILITY_PVT.Query_Row
								( p_wip_entity_id       => l_wip_entity_id
								, p_organization_id     => l_organization_id
								, x_eam_wo_rec          => l_old_eam_wo_rec
								, x_Return_status       => l_return_status
								);
						l_eam_wo_rec := l_old_eam_wo_rec;
				end if;

				--fix for 3550864.create the requisitions for newly added osp items for a workorder already in released status
				if( l_eam_wo_rec.status_type = 3
				and l_old_eam_wo_rec.status_type = 3
				and nvl(l_eam_wo_rec.po_creation_time,2)=WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE
				) then
						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
							EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Calling EAM_RES_UTILITY_PVT.CREATE_OSP_REQ to create requisitions for osp item for already released workorder');
						END IF;
						EAM_RES_UTILITY_PVT.CREATE_OSP_REQ
						(
								p_eam_res_tbl => p_eam_res_tbl,
								x_return_status => l_return_status
						);

						if(nvl(l_return_status,'S') <> 'S') then
								l_eam_return_status := l_return_status;
								RAISE OSP_REQ_ERR;
						end if;
				end if;
                                -- flag l_woru_modified will check if resource usage records have modified or not.

                                l_woru_modified := 'N' ;
                                l_res_usage_tbl_index := l_eam_res_usage_tbl.FIRST ;

                                WHILE  l_res_usage_tbl_index IS NOT NULL LOOP

                                           IF (l_eam_res_usage_tbl( l_res_usage_tbl_index ).old_start_date <> l_eam_res_usage_tbl( l_res_usage_tbl_index ).start_date  OR

                                              l_eam_res_usage_tbl( l_res_usage_tbl_index ).old_completion_date <> l_eam_res_usage_tbl( l_res_usage_tbl_index ).completion_date )
                                           THEN
                                           l_woru_modified := 'Y' ;
                                           END IF;
                                           l_res_usage_tbl_index := l_eam_res_usage_tbl.NEXT(l_res_usage_tbl_index);
                                END LOOP;

								--change for bug 9138126
								-- Also check resource instance modifications for updating l_woru_modified value
                                -- Assign Employee page does not pass resource usage record.It passes only instance usage record.

                                l_res_inst_usage_tbl_index := l_eam_res_inst_tbl.FIRST ;

                                WHILE  l_res_inst_usage_tbl_index IS NOT NULL LOOP


                                        BEGIN

                                          SELECT	Min(start_date), Max(completion_date)
                                          INTO l_min_res_usg_start_date,l_max_res_usg_compl_date
				                                  FROM	wip_operation_resources
				                                  WHERE	wip_entity_id = l_eam_res_inst_tbl( l_res_inst_usage_tbl_index ).WIP_ENTITY_ID
				                                  AND	operation_seq_num = l_eam_res_inst_tbl( l_res_inst_usage_tbl_index ).operation_seq_num
				                                  AND	organization_id = l_eam_res_inst_tbl( l_res_inst_usage_tbl_index ).ORGANIZATION_ID
				                                  AND	resource_seq_num = l_eam_res_inst_tbl( l_res_inst_usage_tbl_index ).resource_seq_num ;
                                        EXCEPTION when NO_DATA_FOUND then
				                                  null;
		                                END;

                                        IF (l_min_res_usg_start_date IS NOT NULL and l_max_res_usg_compl_date IS NOT NULL ) THEN
                                           IF (l_min_res_usg_start_date > l_eam_res_inst_tbl( l_res_inst_usage_tbl_index ).start_date  OR
                                              l_max_res_usg_compl_date < l_eam_res_inst_tbl( l_res_inst_usage_tbl_index ).completion_date )
                                           THEN
											l_woru_modified := 'Y' ;
                                           END IF;
										END IF;
                                           l_res_inst_usage_tbl_index := l_eam_res_inst_tbl.NEXT(l_res_inst_usage_tbl_index);
                                END LOOP;

								--end change 9138126

				-- WO Scheduling

				--3521842   --if set to call the scheduler
				-- 3780116  Change done for DS
				-- do not call material shortage for CMRO
				IF l_eam_wo_rec.maintenance_object_source = 1 THEN

						IF l_material_shortage = G_MATERIAL_UPDATE THEN
								IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO :Calling the Check_Shortage procedure for materials'); END IF;
								eam_material_validate_pub.Check_Shortage
										(
												p_api_version		=>  1.0
												, x_return_status	=> l_return_status
												, x_msg_count		=>  l_msg_count
												, x_msg_data		=> l_msg_data
												, p_wip_entity_id	=> l_eam_wo_rec.wip_entity_id
												, x_shortage_exists	=> x_shortage_exists
												, p_source_api		=> 'EAMVWOPB.pls'
										);
								begin
										select material_shortage_check_date,
										material_shortage_flag
										into l_eam_wo_rec.material_shortage_check_date ,
										l_eam_wo_rec.material_shortage_flag
										from EAM_WORK_ORDER_DETAILS
										where wip_entity_id = l_eam_wo_rec.wip_entity_id;
								exception
										when no_data_found then
										null;
								end ;

						END IF;
				END IF;

				IF l_scheduled=G_SCHEDULE_WO AND NVL(l_eam_wo_rec.ds_scheduled_flag,'N')='N' THEN
           IF (nvl(l_eam_wo_rec.source_code, 'X') NOT IN ('MSC','AHL') ) THEN --EAM related changes in PS-CMRO Integration  bug 9413058
                    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||'EAM_PROCESS_WO_PVT.PROCESS_WO :Scheduling WO') ; END IF ;
                    EAM_WO_SCHEDULE_PVT.SCHEDULE_WO
                                        (  p_organization_id               =>  l_eam_wo_rec.organization_id
                                        ,  p_wip_entity_id                 =>  l_eam_wo_rec.wip_entity_id
                                        ,  p_start_date                    =>  l_eam_wo_rec.requested_start_date
                                        ,  p_completion_date               =>  l_eam_wo_rec.due_date
                                        ,  p_validation_level              =>  null
                                        ,  p_commit                        =>  'N'
                                        ,  x_error_message                 =>  l_err_text
                                        ,  x_return_status                 =>  l_return_status
                                        );
            ELSE
                        l_return_status := 'S';
            END IF;
						IF NVL(l_return_status, 'S') = 'Q' THEN
								l_return_status := 'F';
								RAISE G_EXC_QUIT_IMPORT;

						ELSIF NVL(l_return_status, 'S') = 'U' THEN
								RAISE G_EXC_QUIT_IMPORT;

						ELSIF NVL(l_return_status, 'S') <> 'S' THEN
								l_eam_return_status := l_return_status;

						END IF;
				ELSE IF    l_bottomup_scheduled IN ( G_BU_SCHEDULE_WO, G_UPDATE_RES_USAGE ) THEN

						IF ( l_bottomup_scheduled = G_UPDATE_RES_USAGE ) THEN
								l_out_eam_res_tbl           := l_eam_res_tbl;
								l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
								l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;

								IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO :Calling update_resource_usage for firm work orders') ; END IF ;

								EAM_SCHED_BOTTOM_UP_PVT.update_resource_usage(
										p_eam_res_tbl		=> l_eam_res_tbl
										, p_eam_res_inst_tbl    => l_eam_res_inst_tbl
										, p_eam_res_usage_tbl   => l_eam_res_usage_tbl
										, x_eam_res_tbl		=> l_out_eam_res_tbl
										, x_eam_res_usage_tbl   => l_out_eam_res_usage_tbl
										, x_eam_res_inst_tbl    => l_out_eam_res_inst_tbl
										, x_return_status       => l_return_status
										, x_message_name	=> l_err_text
										) ;

								IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
									EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : update_resource_usage for firm work orders returned status is ' || l_return_status ) ;
								END IF ;
								IF NVL(l_return_status, 'T') <> 'S' THEN
										l_eam_return_status := l_return_status;
										l_return_status := 'E';
										RAISE UPDATE_RES_USAGE_BU_ERR;
								END IF;

								l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
								l_eam_res_tbl		:= l_out_eam_res_tbl;
								l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;

						END IF;
				END IF;
		END IF;
     -- bug 13493098
		if l_scheduled = G_FIRM_WORKORDER or NVL(l_eam_wo_rec.ds_scheduled_flag,'N')= 'Y' or (nvl(l_eam_wo_rec.source_code, 'X') IN ('AHL') ) then

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Checking WO dates to see whether they are correctly encompassed...') ; END IF ;

				EAM_WO_NETWORK_DEFAULT_PVT.Check_Wo_Dates
				(
						p_api_version                   => 1.0,
						p_init_msg_list                 => FND_API.G_FALSE,
						p_commit                        => FND_API.G_FALSE,
						p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

						p_wip_entity_id                 => l_eam_wo_rec.wip_entity_id,

						x_return_status                 => l_return_status,
						x_msg_count                     => l_msg_count,
						x_msg_data                      => l_err_text
				);

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Check_Wo_Dates completed with status of '||l_return_status) ; END IF ;

				IF NVL(l_return_status, 'T') <> 'S' THEN


						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Calling schedule_bottom_up_pvt for firm work orders') ; END IF ;

				--Added parameter p_woru_modified to the procedure. This is done to ensure that dates are changed correctly from summary tab in Create Update WO page

						EAM_SCHED_BOTTOM_UP_PVT.schedule_bottom_up_pvt (
								p_api_version_number    => 1.0
								, p_commit		   => FND_API.G_FALSE
								, p_wip_entity_id         => l_eam_wo_rec.wip_entity_id
								, p_org_id                => l_eam_wo_rec.organization_id
								, p_woru_modified         => l_woru_modified
								, x_return_status         => l_return_status
								, x_message_name	   => l_err_text
						) ;

						  /*7570880 start -Fp of 7003588 for eAM Reconcilation */
 	             l_token_tbl(1).token_name  := 'WORK_ORDER_NAME';
 	             l_token_tbl(1).token_value :=  l_eam_wo_rec.wip_entity_name;

 	             l_out_mesg_token_tbl  := l_mesg_token_tbl;
 	             EAM_ERROR_MESSAGE_PVT.Add_Error_Token
 	             (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
 	              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
 	              , p_message_name   => 'EAM_SCHED_BOTTOMUP_MSG'
 	              , p_token_tbl      => l_token_tbl
 	              );
 	             l_mesg_token_tbl      := l_out_mesg_token_tbl;

 	            -- l_return_status := FND_API.G_RET_STS_ERROR;

 	              l_out_eam_wo_rec            := l_eam_wo_rec;
 	          l_out_eam_op_tbl            := l_eam_op_tbl;
 	          l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
 	          l_out_eam_res_tbl           := l_eam_res_tbl;
 	          l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
 	          l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
 	          l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
 	          l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
 	          l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
 	         EAM_ERROR_MESSAGE_PVT.Log_Error
 	         (  p_eam_wo_rec             => l_eam_wo_rec
 	         ,  p_eam_op_tbl             => l_eam_op_tbl
 	         ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
 	         ,  p_eam_res_tbl            => l_eam_res_tbl
 	         ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
 	         ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
 	         ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
 	         ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
 	         ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
 	         ,  p_mesg_token_tbl         => l_mesg_token_tbl
 	         ,  p_error_status           => FND_API.G_RET_STS_ERROR
 	         ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
 	         ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
 	         ,  p_other_message          => l_other_message
 	         ,  p_other_token_tbl        => l_other_token_tbl
 	         ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
 	         ,  x_eam_wo_rec             => l_out_eam_wo_rec
 	         ,  x_eam_op_tbl             => l_out_eam_op_tbl
 	         ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
 	         ,  x_eam_res_tbl            => l_out_eam_res_tbl
 	         ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
 	         ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
 	         ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
 	         ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
 	         ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
 	         );
 	         /* l_eam_wo_rec                := l_out_eam_wo_rec;
 	          l_eam_op_tbl                := l_out_eam_op_tbl;
 	          l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
 	          l_eam_res_tbl               := l_out_eam_res_tbl;
 	          l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
 	          l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
 	          l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
 	          l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
 	          l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;         */


 	         l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

 	         x_msg_count                    := l_msg_count;
 	       /*  x_return_status                := l_return_status;
 	         x_eam_wo_rec                   := l_eam_wo_rec;
 	         x_eam_op_tbl                   := l_eam_op_tbl;
 	         x_eam_op_network_tbl           := l_eam_op_network_tbl;
 	         x_eam_res_tbl                  := l_eam_res_tbl;
 	         x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
 	         x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
 	         x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
 	         x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
 	         x_eam_direct_items_tbl              := l_eam_direct_items_tbl;         */


 	             fnd_message.set_name('EAM','EAM_SCHED_BOTTOMUP_MSG');


 	                                                /*7570880 end -Fp of 7003588 for eAM Reconcilation */

						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : schedule_bottom_up_pvt for firm work orders return status :' ||l_return_status) ; END IF ;
						IF NVL(l_return_status, 'T') <> 'S' THEN
								l_eam_return_status := l_return_status;
								l_return_status := 'E';
								RAISE SCHEDULE_BOTTOM_UP_ERR;
						END IF;
				END IF;
		END IF;

		/*l_eam_wo_rec            := l_out_eam_wo_rec;
		l_eam_op_tbl            := l_out_eam_op_tbl;
		l_eam_res_tbl           := l_out_eam_res_tbl;
		l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl; */



		--find out if the assignment status has to be calculated again or not
		IF((l_scheduled=G_SCHEDULE_WO) OR (l_bottomup_scheduled IN ( G_BU_SCHEDULE_WO, G_UPDATE_RES_USAGE ))
		OR (l_eam_res_tbl.COUNT > 0) OR (l_eam_res_usage_tbl.COUNT > 0) OR (l_eam_res_inst_tbl.COUNT > 0)
		) THEN
				l_emp_assignment := TRUE;
		END IF;

		IF ( l_emp_assignment = TRUE ) THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Updating assignment details of an employee ') ; END IF ;

				Update eam_work_order_details
				set  ASSIGNMENT_COMPLETE = EAM_ASSIGN_EMP_PUB.Get_Emp_Assignment_Status(l_eam_wo_rec.wip_entity_id,l_eam_wo_rec.organization_id)
				where wip_entity_id = l_eam_wo_rec.wip_entity_id;
		END IF;

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Checking Operation Network Dates... ') ; END IF ;

		EAM_OP_VALIDATE_PVT.Check_Operation_Netwrok_Dates
		(
				p_api_version                   => 1.0,
				p_init_msg_list                 => FND_API.G_FALSE,
				p_commit                        => FND_API.G_FALSE,
				p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
				p_wip_entity_id                 => l_eam_wo_rec.wip_entity_id,
				x_return_status                 => l_return_status,
				x_pri_operation_no              => l_prior_op_no,
				x_next_operation_no             => l_next_op_no
		);

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Check_Operation_Netwrok_Dates completed with status of '||l_return_status) ; END IF ;

		IF NVL(l_return_status, 'T') <> 'S' THEN
				l_eam_return_status := l_return_status;
				l_return_status := 'E';
				RAISE CHECK_OP_NETWORK_DATES_ERR;
		END IF;


		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Scheduling WO completed with status ' || l_return_status) ; END IF ;

        -- Even for firm work orders, make sure that the work order dates
        -- encompass the operation dates and that the operation dates
        -- encompass the resource dates and that the resource dates
        -- encompass the resource instance dates.

        if l_scheduled = G_FIRM_WORKORDER then

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Calling Check_Resource_Dates procedure ...') ; END IF ;

				EAM_WO_NETWORK_DEFAULT_PVT.Check_Resource_Dates
				(
						p_api_version                   => 1.0,
						p_init_msg_list                 => FND_API.G_FALSE,
						p_commit                        => FND_API.G_FALSE,
						p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

						p_wip_entity_id                 => l_eam_wo_rec.wip_entity_id,

						x_return_status                 => l_return_status,
						x_msg_count                     => l_msg_count,
						x_msg_data                      => l_err_text
				);
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Check_Resource_Dates completed with status of '||l_return_status) ; END IF ;

				IF NVL(l_return_status, 'T') <> 'S' THEN
						l_eam_return_status := l_return_status;
						l_return_status := 'E';
						RAISE CHECK_WO_RES_DATES_ERR;
				END IF;

		end if;

		begin
				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Calling Check_Wo_Negative_Dates procedure ... ') ; END IF ;
				EAM_WO_NETWORK_DEFAULT_PVT.Check_Wo_Negative_Dates
				(
						p_api_version                   => 1.0,
						p_init_msg_list                 => FND_API.G_FALSE,
						p_commit                        => FND_API.G_FALSE,
						p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
						p_wip_entity_id                 => l_eam_wo_rec.wip_entity_id,
						p_organization_id               => l_eam_wo_rec.organization_id,
						x_return_status                 => l_return_status,
						x_msg_count                     => l_msg_count,
						x_msg_data                      => l_err_text
				);

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Check_Wo_Negative_Dates completed with status of '||l_return_status) ; END IF ;

				IF NVL(l_return_status, 'T') <> 'S' THEN
						l_eam_return_status := l_return_status;
						l_return_status := 'E';
						RAISE CHECK_WO_NEGATIVE_DATES_ERR;
				END IF;

		end;


     IF NVL(l_eam_wo_rec.source_code,'X') <> 'MSC' THEN --EAM related changes in PS-CMRO Integration  bug 9413058

       if NVL(l_eam_wo_rec.validate_structure,'N') <> 'Y' then -- check added for bug# 3544860

				    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Calling Validate_Structure API'); END IF;

          EAM_WO_NETWORK_VALIDATE_PVT.Validate_Structure
				   (
						p_api_version                   => 1.0,
						p_init_msg_list                 => FND_API.G_FALSE,
						p_commit                        => FND_API.G_FALSE,
						p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

						p_work_object_id                => l_eam_wo_rec.wip_entity_id,
						p_work_object_type_id           => 1,
						p_exception_logging             => 'Y',

						p_validate_status		=> 'N',
						p_output_errors			=> 'N',

						x_return_status                 => l_return_status,
						x_msg_count                     => l_msg_count,
						x_msg_data                      => l_err_text,
						x_wo_relationship_exc_tbl	=> l_wo_relationship_exc_tbl
            );

				--call the validate structure.
				IF nvl(l_return_status,'T') <> 'S' THEN
						l_eam_return_status := l_return_status;
						l_return_status := 'E';
						RAISE VALIDATE_NETWORK_ERR;
				END IF;

      END IF;

		end if;

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : enters inside update'); END IF;
		UPDATE_DATES(l_eam_wo_rec,
				l_eam_op_tbl,
				l_eam_res_tbl,
				l_eam_res_inst_tbl);
		end if;    --end of check for l_eam_return_status and 'S'

        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        -- Load out parameters
		IF nvl(l_eam_return_status,'S') <> 'S' THEN
				x_return_status                := l_eam_return_status;
		END IF;

		IF l_eam_return_status = 'S' THEN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Updating WIP_REQUIREMENT_OPERATIONS'); END IF;

				begin
						select operation_seq_num,first_unit_start_date
								bulk collect into l_wkorder_new_op_tbl,l_wkorder_new_op_dt_tbl
								from wip_operations
								where  organization_id = l_organization_id
								and  wip_entity_id = l_wip_entity_id;
				exception when others then
								null;
				end;

				IF l_wkorder_old_op_tbl.COUNT > 0 THEN

						FOR ii in l_wkorder_old_op_tbl.FIRST..l_wkorder_old_op_tbl.LAST LOOP
								IF l_wkorder_new_op_tbl.COUNT > 0 THEN
										FOR jj in l_wkorder_new_op_tbl.FIRST..l_wkorder_new_op_tbl.LAST LOOP
												IF l_wkorder_old_op_tbl(ii) = l_wkorder_new_op_tbl(jj) THEN
														IF l_wkorder_old_op_dt_tbl(ii) <> l_wkorder_new_op_dt_tbl(jj) THEN

																no_of_days := l_wkorder_new_op_dt_tbl(jj)-l_wkorder_old_op_dt_tbl(ii);
																update WIP_REQUIREMENT_OPERATIONS
																set date_required = date_required + no_of_days
																where organization_id = l_organization_id
																and wip_entity_id = l_wip_entity_id
																and operation_seq_num = l_wkorder_old_op_tbl(ii);
														END IF;
												END IF;
										END LOOP;
								END IF;
						END LOOP;
				-- condition for bug 5258151
				ELSE IF l_eam_wo_rec.transaction_type = G_OPR_CREATE and l_wkorder_new_op_tbl.count > 0 THEN
								FOR jj in l_wkorder_new_op_tbl.FIRST..l_wkorder_new_op_tbl.LAST LOOP
										update WIP_REQUIREMENT_OPERATIONS
										set date_required = l_wkorder_new_op_dt_tbl(jj)
										where organization_id = l_organization_id
										and wip_entity_id = l_wip_entity_id
										and operation_seq_num = l_wkorder_new_op_tbl(jj);
								END LOOP;
						END IF;
				END IF;			--- end of l_wkorder_old_op_tbl.COUNT

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Updating date required columns for WIP_REQUIREMENT_OPERATIONS'); END IF;

				IF l_wip_entity_id IS NOT NULL THEN
						select SCHEDULED_START_DATE into l_wo_new_sch_start_date
						from wip_discrete_jobs
						where wip_entity_id = l_wip_entity_id;
				END IF;

				IF l_wo_old_sch_start_date <> l_wo_new_sch_start_date THEN
						update wip_requirement_operations
						set date_required = date_required + (l_wo_new_sch_start_date-l_wo_old_sch_start_date)
						where operation_seq_num = 1
						and organization_id = l_organization_id
						and wip_entity_id = l_wip_entity_id ;
				END IF;

				 --Code added to sync up WORI with WOR when resource dates are modified from summary tab
                                   IF l_woru_modified ='N' THEN

                                                   FOR c_opresource_rec IN get_opresource_csr(l_eam_wo_rec.wip_entity_id) LOOP

                                                   UPDATE        wip_op_resource_instances
                                                   SET        start_date = c_opresource_rec.start_date,
                                                           completion_date=c_opresource_rec.completion_date
                                                   WHERE        wip_entity_id = l_wip_entity_id
                                                   AND        operation_seq_num = c_opresource_rec.operation_seq_num
                                                   AND        resource_seq_num = c_opresource_rec.resource_seq_num;

                                                   END LOOP;

                                   END IF;



				--added code for bug 5449296 from EAMPWOPB.pls

				/* Failure Entry Project Start*/
				IF( l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
						AND l_eam_wo_rec.eam_failure_entry_record.failure_date is not null
						) THEN
						l_eam_wo_rec.eam_failure_entry_record.source_id := l_eam_wo_rec.wip_entity_id;
				END IF;

				If( l_eam_wo_rec.eam_failure_entry_record.transaction_type is not null) then

						EAM_Process_Failure_Entry_PUB.Process_Failure_Entry
						(
								p_eam_failure_entry_record   => l_eam_wo_rec.eam_failure_entry_record
								, p_eam_failure_codes_tbl      => l_eam_wo_rec.eam_failure_codes_tbl
								, x_return_status              => l_return_status
								, x_msg_count                  => l_msg_count
								, x_msg_data                   => l_msg_data
								, x_eam_failure_entry_record   => x_eam_wo_rec.eam_failure_entry_record
								, x_eam_failure_codes_tbl      => x_eam_wo_rec.eam_failure_codes_tbl
						);

						IF NVL(l_return_status, 'T') <> 'S' THEN
								l_eam_return_status := 'E';
								RAISE EXC_ERR_PVT_API_MAIN;
						END IF;

						l_eam_wo_rec.eam_failure_entry_record   := x_eam_wo_rec.eam_failure_entry_record ;   --copy output variables back to local
						l_eam_wo_rec.eam_failure_codes_tbl      := x_eam_wo_rec.eam_failure_codes_tbl;
				END IF;
				/* Failure Entry Project End */

				-- Stock Issue requirements
				If l_eam_wo_rec.material_issue_by_mo = 'Y' and
						l_eam_wo_rec.maintenance_object_source = 1 and -- Only for EAM
						((l_eam_wo_rec.status_type in (3,5,7) and    --release or cancel a workorder
						--Added for bug 7631627
						l_eam_wo_rec.status_type <> l_old_eam_wo_rec.status_type) OR
						(l_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE and
						l_eam_wo_rec.status_type = 3)
						) then

						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Calling material Allocation procedure at wo release/cancel ... ') ; END IF ;

						EAM_MATERIALISSUE_PVT.alloc_at_release_cancel (
								p_api_version        => 1.0,
								p_init_msg_list      => fnd_api.g_false,
								p_commit             => fnd_api.g_false,
								p_validation_level   => fnd_api.g_valid_level_full,
								p_wip_entity_id      => l_eam_wo_rec.wip_entity_id,
								p_organization_id    => l_eam_wo_rec.organization_id,
								p_status_type        => l_eam_wo_rec.status_type,
								x_return_status      => l_return_status,
								x_msg_data           => l_err_text,
								x_msg_count          => l_msg_count
						);


						IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Allocation creation at wo release/cancel completed with status of '||l_return_status) ; END IF ;

						IF NVL(l_return_status, 'T') <> 'S' THEN
								l_eam_return_status := 'E';
								RAISE ALLOC_CREATION_ERR;
						END IF;

				End if;     --end of if for stock issue enhancements


				IF l_out_eam_mat_req_tbl.COUNT > 0 THEN

						FOR kk in l_out_eam_mat_req_tbl.FIRST..l_out_eam_mat_req_tbl.LAST LOOP
								IF(NVL(l_out_eam_mat_req_tbl(kk).invoke_allocations_api,'N') ='Y') THEN

										EAM_MATERIALISSUE_PVT.comp_alloc_chng_qty
										(
												p_api_version        => 1.0,
												p_init_msg_list      => fnd_api.g_false,
												p_commit             => fnd_api.g_false,
												p_validation_level   => fnd_api.g_valid_level_full,
												p_wip_entity_id      => l_out_eam_mat_req_tbl(kk).wip_entity_id,
												p_organization_id    => l_out_eam_mat_req_tbl(kk).organization_id,
												p_operation_seq_num  => l_out_eam_mat_req_tbl(kk).operation_seq_num,
												p_inventory_item_id  => l_out_eam_mat_req_tbl(kk).inventory_item_id,
												p_qty_required       => l_out_eam_mat_req_tbl(kk).required_quantity,
                                                                                                p_supply_subinventory => l_out_eam_mat_req_tbl(kk).supply_subinventory,
                                                                                                p_supply_locator_id  => l_out_eam_mat_req_tbl(kk).supply_locator_id,
												x_return_status      => l_return_status,
												x_msg_data           => l_err_text,
												x_msg_count          => l_msg_count
										);

								END IF;

								IF l_old_eam_wo_rec.status_type in (3,4) -- released, complete
										and l_out_eam_mat_req_tbl(kk).transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
										THEN
										EAM_MATERIALISSUE_PVT.cancel_alloc_matl_del
										(
												p_api_version           => 1.0,
												p_init_msg_list         => fnd_api.g_false,
												p_commit                => fnd_api.g_false,
												p_validation_level      => fnd_api.g_valid_level_full,
												p_wip_entity_id         => l_out_eam_mat_req_tbl(kk).wip_entity_id,
												p_operation_seq_num     => l_out_eam_mat_req_tbl(kk).operation_seq_num,
												p_inventory_item_id     => l_out_eam_mat_req_tbl(kk).inventory_item_id,
												p_wip_entity_type       => WIP_CONSTANTS.EAM,
												p_repetitive_schedule_id => null,
												x_return_status         => l_return_status,
												x_msg_data              => l_err_text,
												x_msg_count             => l_msg_count
										);

								END IF;
						END LOOP;

				END IF;		--end of if l_out_eam_mat_req_tbl.COUNT

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling UPDATE_INTERMEDIA_INDEX'); END IF;

				IF(l_eam_wo_rec.maintenance_object_source =1 ) THEN   --update intermedia index only for EAM workorders
				UPDATE_INTERMEDIA_INDEX
				(
						l_eam_wo_rec,
						l_old_eam_wo_rec,
						l_eam_op_tbl,
						l_eam_res_tbl,
						l_eam_res_inst_tbl
				);
				END IF;     --end of check for maint. object source...

		END IF;		--end of l_eam_return_status='S'

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_PROCESS_WO_PVT.PROCESS_WO : Assigning Out Parameters'); END IF;

		x_msg_count                    := l_msg_count;
		x_eam_wo_rec                   := l_eam_wo_rec;
		x_eam_op_tbl                   := l_eam_op_tbl;
		x_eam_op_network_tbl           := l_eam_op_network_tbl;
		x_eam_res_tbl                  := l_eam_res_tbl;
		x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
		x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
		x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
		x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
		x_eam_direct_items_tbl         := l_eam_direct_items_tbl;
		x_return_status                := l_eam_return_status;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.PROCESS_WO : End ==== Return status: '||x_return_status||' =======================') ; END IF ;

EXCEPTION

     WHEN ALLOC_CREATION_ERR THEN

            l_token_tbl(1).token_name  := 'Wip_Entity_Id';
            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WO_ALLOC_CR_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

         l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
         l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
         l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
         l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

       l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl         := l_eam_direct_items_tbl;

    WHEN EXC_ERR_PVT_API_MAIN THEN

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


    WHEN OSP_REQ_ERR THEN

           l_token_tbl(1).token_name  := 'WIPENTITYID';
            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WO_OSP_REQ_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl      := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

WHEN UPDATE_RES_USAGE_BU_ERR THEN

     l_token_tbl(1).token_name  := 'WORK_ORDER_NAME';
     l_token_tbl(1).token_value :=  l_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => l_err_text
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
	,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

WHEN SCHEDULE_BOTTOM_UP_ERR THEN

     l_token_tbl(1).token_name  := 'WORK_ORDER_NAME';
     l_token_tbl(1).token_value :=  l_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => l_err_text
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
	,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

 WHEN CHECK_OP_NETWORK_DATES_ERR THEN

     l_token_tbl(1).token_name  := 'OP_SEQ_NO';
     l_token_tbl(1).token_value :=  l_prior_op_no || ',' || l_next_op_no;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_OP_NETWRK_DATES_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


    WHEN CHECK_WO_DATES_ERR THEN

            l_token_tbl(1).token_name  := 'WorkOrder';
--            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

    SELECT wip_entity_name into l_token_tbl(1).token_value
	 FROM  WIP_ENTITIES we
	 WHERE we.wip_entity_id = l_eam_wo_rec.wip_entity_id
	 AND   we.organization_id = l_eam_wo_rec.organization_id;


            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WO_CHK_DATES_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

    WHEN CHECK_WO_RES_DATES_ERR THEN

            l_token_tbl(1).token_name  := 'WorkOrder';
--            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

    SELECT wip_entity_name into l_token_tbl(1).token_value
	 FROM  WIP_ENTITIES we
	 WHERE we.wip_entity_id = l_eam_wo_rec.wip_entity_id
	 AND   we.organization_id = l_eam_wo_rec.organization_id;


            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'CHECK_WO_RES_DATES_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;

    WHEN CHECK_WO_NEGATIVE_DATES_ERR THEN
         l_token_tbl(1).token_name  := 'Wip Entity Id';
            l_token_tbl(1).token_value := l_eam_wo_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WO_CHK_NEGATIVE_DATES_ERR'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
		(  p_eam_wo_rec             => l_eam_wo_rec
		,  p_eam_op_tbl             => l_eam_op_tbl
		,  p_eam_op_network_tbl     => l_eam_op_network_tbl
		,  p_eam_res_tbl            => l_eam_res_tbl
		,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
		,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
		,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
		,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
		       ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
		,  p_mesg_token_tbl         => l_mesg_token_tbl
		,  p_error_status           => FND_API.G_RET_STS_ERROR
		,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
		,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
		,  p_other_message          => l_other_message
		,  p_other_token_tbl        => l_other_token_tbl
		,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
		,  x_eam_wo_rec             => l_out_eam_wo_rec
		,  x_eam_op_tbl             => l_out_eam_op_tbl
		,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
		,  x_eam_res_tbl            => l_out_eam_res_tbl
		,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
		,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
		,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
		,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
		       ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
		);
		 l_eam_wo_rec                := l_out_eam_wo_rec;
		 l_eam_op_tbl                := l_out_eam_op_tbl;
		 l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
		 l_eam_res_tbl               := l_out_eam_res_tbl;
		 l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
		 l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
		 l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
		 l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
		 l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


		l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

		x_msg_count                    := l_msg_count;
		x_return_status                := l_return_status;
		x_eam_wo_rec                   := l_eam_wo_rec;
		x_eam_op_tbl                   := l_eam_op_tbl;
		x_eam_op_network_tbl           := l_eam_op_network_tbl;
		x_eam_res_tbl                  := l_eam_res_tbl;
		x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
		x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
		x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
		x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
		x_eam_direct_items_tbl              := l_eam_direct_items_tbl;
    WHEN VALIDATE_NETWORK_ERR THEN

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WN_MAIN_VALIDATE_STRUCT'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;


        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl         := l_eam_direct_items_tbl;


    WHEN G_EXC_QUIT_IMPORT THEN

        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


    WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME || ' : Process WO ' || substrb(SQLERRM,1,200);
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Text => l_err_text
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
                 );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
    END IF;


	 l_out_eam_wo_rec            := l_eam_wo_rec;
         l_out_eam_op_tbl            := l_eam_op_tbl;
  	 l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
         l_out_eam_res_tbl           := l_eam_res_tbl;
         l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
	 l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
         l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
         l_out_eam_direct_items_tbl       := l_eam_direct_items_tbl;
         l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );
	 l_eam_wo_rec                := l_out_eam_wo_rec;
         l_eam_op_tbl                := l_out_eam_op_tbl;
         l_eam_op_network_tbl        := l_out_eam_op_network_tbl;
         l_eam_res_tbl               := l_out_eam_res_tbl;
         l_eam_res_inst_tbl          := l_out_eam_res_inst_tbl;
         l_eam_sub_res_tbl           := l_out_eam_sub_res_tbl;
         l_eam_mat_req_tbl           := l_out_eam_mat_req_tbl;
         l_eam_direct_items_tbl           := l_out_eam_direct_items_tbl;
         l_eam_res_usage_tbl         := l_out_eam_res_usage_tbl;

        l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

        x_msg_count                    := l_msg_count;
        x_return_status                := l_return_status;
        x_eam_wo_rec                   := l_eam_wo_rec;
        x_eam_op_tbl                   := l_eam_op_tbl;
        x_eam_op_network_tbl           := l_eam_op_network_tbl;
        x_eam_res_tbl                  := l_eam_res_tbl;
        x_eam_res_inst_tbl             := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl              := l_eam_direct_items_tbl;


END PROCESS_WO;


/**************************************************************************
* Procedure :     Validate_Transaction_Type
* Parameters IN : Transaction Type
*                 Entity Name
*                 Entity ID, so that it can be used in a meaningful message
* Parameters OUT NOCOPY: Valid flag
*                 Message Token Table
* Purpose :       This procedure will check if the transaction type is valid
*                 for a particular entity.
***************************************************************************/
PROCEDURE Validate_Transaction_Type
(   p_transaction_type              IN  NUMBER
,   p_entity_name                   IN  VARCHAR2
,   p_entity_id                     IN  VARCHAR2
,   x_valid_transaction             OUT NOCOPY BOOLEAN
,   x_Mesg_Token_Tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)
IS
l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_out_mesg_token_tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

BEGIN
    l_token_tbl(1).token_name := 'WIP_ENTITY_ID';
    l_token_tbl(1).token_value := p_entity_id;

    x_valid_transaction := TRUE;


    IF (p_entity_name IN ('WORK_ORDER')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_SYNC, EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)
       )
       OR
       (p_entity_name IN ('OPERATION','OPERATION_RESOURCE','RESOURCE_INSTANCE','SUB_RESOURCE','DIRECT_ITEMS','MATERIAL_REQUIREMENTS')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_SYNC, EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
       )
       OR
       (p_entity_name IN ('OPERATION_NETWORK', 'RESOURCE_USAGE')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
       )
       OR
       (p_entity_name IN ('WORK_ORDER_COMPLETEION','OPERATION_COMPLETEION')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_COMPLETE, EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE)
	)
       OR
       (p_entity_name IN ('QUALITY_ENTRY','METER_READING')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_CREATE)
	)
       OR
       (p_entity_name IN ('WORK_ORDER_COMPL_REBUILD','W_ORDER_COMPL_METER_READING')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE)
        )
       OR
       (p_entity_name IN ('WORK_SERVICE_REQUEST')
        AND NVL(p_transaction_type, FND_API.G_MISS_NUM) NOT IN (EAM_PROCESS_WO_PVT.G_OPR_CREATE,EAM_PROCESS_WO_PVT.G_OPR_UPDATE)
	)

    THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            IF p_entity_name = 'WORK_ORDER'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_WO_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'OPERATION'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_OP_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'OPERATION_NETWORK'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_OPN_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'OPERATION_RESOURCE'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_RES_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'SUB_RESOURCE'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_SR_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'RESOURCE_INSTANCE'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_RI_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'RESOURCE_USAGE'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_RU_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'MATERIAL_REQUIREMENTS'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_MR_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            ELSIF p_entity_name = 'DIRECT_ITEMS'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_DI_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'WORK_ORDER_COMPLETEION'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_WOCOMPL_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'OPERATION_COMPLETEION'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_OPCOMPL_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'QUALITY_ENTRY'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_QA_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'METER_READING'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_MR_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'WORK_ORDER_COMPL_REBUILD'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_WOCOMRB_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'W_ORDER_COMPL_METER_READING'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_WOCOMMR_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
	    ELSIF p_entity_name = 'WORK_SERVICE_REQUEST'
            THEN
                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_Name       => 'EAM_WORSER_TXN_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_out_Mesg_Token_Tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;
            END IF;
        END IF;

        x_mesg_token_tbl := l_Mesg_Token_Tbl;
        x_valid_transaction := FALSE;

    END IF;

END Validate_Transaction_Type;


PROCEDURE Set_Debug
    (  p_debug_flag     IN  VARCHAR2 )
    IS
BEGIN
          EAM_PROCESS_WO_PUB.g_debug_flag := p_debug_flag;
END Set_Debug;


FUNCTION Get_Debug RETURN VARCHAR2
    IS
BEGIN
          RETURN EAM_PROCESS_WO_PUB.g_debug_flag;
END;

--Fix for 3360801.the following procedure will update the records returned by the api with the correct dates

PROCEDURE UPDATE_DATES
        (x_eam_wo_rec IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type,
	 x_eam_op_tbl IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type,
	 x_eam_res_tbl IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type,
	 x_eam_res_inst_tbl IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
)
IS
CURSOR operations
(l_wip_entity_id NUMBER,l_org_id NUMBER,l_op_seq_num NUMBER)
IS
   SELECT first_unit_start_date,
          last_unit_completion_date
   FROM wip_operations
   WHERE wip_entity_id=l_wip_entity_id
   AND organization_id=l_org_id
   AND operation_seq_num=l_op_seq_num;

 l_operations operations%ROWTYPE;

CURSOR resources
(l_wip_entity_id NUMBER,l_org_id NUMBER,l_op_seq_num NUMBER,l_res_seq_num NUMBER)
IS
   SELECT start_date,
          completion_date
   FROM wip_operation_resources
   WHERE wip_entity_id=l_wip_entity_id
   AND organization_id=l_org_id
   AND operation_seq_num=l_op_seq_num
   AND resource_seq_num=l_res_seq_num;

 l_resources resources%ROWTYPE;

 CURSOR resource_instances
(l_wip_entity_id NUMBER,l_org_id NUMBER,l_op_seq_num NUMBER,l_res_seq_num NUMBER,l_instance_id NUMBER,l_serial_number NUMBER)
IS
   SELECT start_date,
          completion_date
   FROM wip_op_resource_instances
   WHERE wip_entity_id=l_wip_entity_id
   AND organization_id=l_org_id
   AND operation_seq_num=l_op_seq_num
   AND resource_seq_num=l_res_seq_num
   AND instance_id=l_instance_id
   AND serial_number(+)=l_serial_number;

 l_resource_instances resource_instances%ROWTYPE;

    i   NUMBER := 0;
    l_start_date  DATE;
    l_completion_date  DATE;
BEGIN

--start of populating workorder dates
IF(x_eam_wo_rec.TRANSACTION_TYPE IN (EAM_PROCESS_WO_PUB.G_OPR_CREATE,EAM_PROCESS_WO_PUB.G_OPR_UPDATE)) THEN
   SELECT scheduled_start_date,scheduled_completion_date
   INTO l_start_date,l_completion_date
   FROM WIP_DISCRETE_JOBS
   WHERE wip_entity_id=x_eam_wo_rec.wip_entity_id
   AND organization_id=x_eam_wo_rec.organization_id;

   x_eam_wo_rec.scheduled_start_date := l_start_date;
   x_eam_wo_rec.scheduled_completion_date := l_completion_date;
END IF;
--end of populating workorder dates

--start of populating operation dates
IF(x_eam_op_tbl.COUNT > 0) THEN
  i:=x_eam_op_tbl.FIRST;
  LOOP
       IF( x_eam_op_tbl(i).TRANSACTION_TYPE IN (EAM_PROCESS_WO_PUB.G_OPR_CREATE,EAM_PROCESS_WO_PUB.G_OPR_UPDATE)) THEN
              OPEN operations(x_eam_wo_rec.wip_entity_id,x_eam_wo_rec.organization_id
			     ,x_eam_op_tbl(i).operation_seq_num);

		FETCH operations INTO l_operations;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('op'||to_char(l_operations.last_unit_completion_date,'DD HH24:MI:SS')); END IF;
                    IF(operations%FOUND) THEN
		        x_eam_op_tbl(i).start_date := l_operations.first_unit_start_date;
			x_eam_op_tbl(i).completion_date := l_operations.last_unit_completion_date;
                    END IF;

              CLOSE operations;

         END IF;
     EXIT WHEN i=x_eam_op_tbl.LAST;
     i:=i+1;
  END LOOP;
END IF;
--end of populating operation dates

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(x_eam_res_tbl.COUNT); END IF;
--start of populating resource dates
IF(x_eam_res_tbl.COUNT > 0) THEN
  i:=x_eam_res_tbl.FIRST;
  LOOP
      IF( x_eam_res_tbl(i).TRANSACTION_TYPE IN (EAM_PROCESS_WO_PUB.G_OPR_CREATE,EAM_PROCESS_WO_PUB.G_OPR_UPDATE)) THEN
              OPEN resources(x_eam_wo_rec.wip_entity_id,x_eam_wo_rec.organization_id
			     ,x_eam_res_tbl(i).operation_seq_num,x_eam_res_tbl(i).resource_seq_num);

			FETCH resources INTO l_resources;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('resources dates passed'||to_char(l_resources.completion_date,'DD HH24:MI:SS')); END IF;
                    IF(resources%FOUND) THEN
			x_eam_res_tbl(i).start_date := l_resources.start_date;
			x_eam_res_tbl(i).completion_date := l_resources.completion_date;
                    END IF;

              CLOSE resources;
       END IF;

     EXIT WHEN i=x_eam_res_tbl.LAST;
     i:=i+1;
  END LOOP;
END IF;
--end of populating resource dates

--start of populating resource instance dates
IF(x_eam_res_inst_tbl.COUNT > 0) THEN
  i:=x_eam_res_inst_tbl.FIRST;
  LOOP
        IF( x_eam_res_inst_tbl(i).TRANSACTION_TYPE IN (EAM_PROCESS_WO_PUB.G_OPR_CREATE,EAM_PROCESS_WO_PUB.G_OPR_UPDATE)) THEN
              OPEN resource_instances(x_eam_wo_rec.wip_entity_id,x_eam_wo_rec.organization_id
			     ,x_eam_res_inst_tbl(i).operation_seq_num,x_eam_res_inst_tbl(i).resource_seq_num
			     ,x_eam_res_inst_tbl(i).instance_id,x_eam_res_inst_tbl(i).serial_number);

			FETCH resource_instances INTO l_resource_instances;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('resource instances  dates passed'||to_char(l_resource_instances.completion_date,'DD HH24:MI:SS')); END IF;
                   IF(resource_instances%FOUND) THEN
			x_eam_res_inst_tbl(i).start_date := l_resource_instances.start_date;
			x_eam_res_inst_tbl(i).completion_date := l_resource_instances.completion_date;
                   END IF;

              CLOSE resource_instances;

	 END IF;
     EXIT WHEN i=x_eam_res_inst_tbl.LAST;
     i:=i+1;
  END LOOP;
END IF;
--end  of populating resource instance dates

EXCEPTION
  WHEN OTHERS THEN
     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Dates could not be populated back to the records') ; END IF ;
END UPDATE_DATES;







 PROCEDURE COMP_UNCOMP_WORKORDER
	(
	   p_eam_wo_comp_rec             IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	 , p_eam_wo_quality_tbl          IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	 , p_eam_meter_reading_tbl       IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , p_eam_counter_prop_tbl        IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , p_eam_wo_comp_mr_read_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	 , x_eam_wo_comp_rec             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	 , x_eam_wo_quality_tbl          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	 , x_eam_meter_reading_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_eam_counter_prop_tbl        OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , x_eam_wo_comp_mr_read_tbl     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	 , x_return_status               OUT NOCOPY VARCHAR2
	 , x_msg_count                   OUT NOCOPY NUMBER
	)IS

	l_valid_transaction		BOOLEAN := TRUE ;
	l_eam_wo_comp_rec		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_out_wo_comp_rec		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;

	l_mesg_token_tbl		EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_return_status			VARCHAR2(1) ;
	l_other_message			VARCHAR2(2000);
	l_other_token_tbl		EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
	msg_index			NUMBER;
	temp_err_mesg			VARCHAR2(4000);
	l_msg_count			NUMBER;

	l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type	:= p_eam_wo_quality_tbl;
	l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type	:= p_eam_meter_reading_tbl;
	l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type := p_eam_wo_comp_rebuild_tbl;
	l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type := p_eam_wo_comp_mr_read_tbl;
	l_eam_counter_prop_tbl			EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type	:= p_eam_counter_prop_tbl;
	l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_out_eam_wo_comp_rec			EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_counter_prop_tbl		EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_transaction_number		NUMBER;
	l_eam_wo_quality_rec		EAM_PROCESS_WO_PUB.eam_wo_quality_rec_type;
	colllection_id_temp			NUMBER;
	l_org_id				NUMBER;
	l_asset_group_id		NUMBER;
	l_asset_number			VARCHAR2(30);
	l_asset_instance_id		NUMBER;
	l_asset_activity_id		NUMBER;
	l_asset_activity		VARCHAR2(240);
	l_asset_group_name		VARCHAR2(240);
	l_wip_entity_name		VARCHAR2(240);
	mandatory_qua_plan		VARCHAR2(1);
	contextStr				VARCHAR2(2000);
	l_wip_entity_id			NUMBER;
	l_out_mesg_token_tbl	EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
	l_msg_data				VARCHAR2(2000);
	l_token_tbl				EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
	l_man_reading_enter		BOOLEAN;
	l_maint_object_type		NUMBER;
	l_maint_object_id		NUMBER;
	l_error_message			VARCHAR2(2000);
	l_instance_number		VARCHAR2(30);  -- From CII table
	l_maint_obj_source              NUMBER;
	l_pending_flag                  VARCHAR2(1);
	l_workflow_enabled              VARCHAR2(1);
	l_approval_required             BOOLEAN;
	l_workflow_name                 VARCHAR2(200);
	l_workflow_process              VARCHAR2(200);
	l_status_pending_event          VARCHAR2(240);
	l_status_changed_event          VARCHAR2(240);
	l_new_eam_status                NUMBER;
	l_new_system_status             NUMBER;
	l_old_eam_status                NUMBER;
        l_old_system_status         NUMBER;
	l_workflow_type                 NUMBER;
	l_event_name			VARCHAR2(240);
	l_parameter_list		wf_parameter_list_t;
	l_event_key				VARCHAR2(200);
	l_wf_event_seq			NUMBER;
	l_cost_estimate         NUMBER;
	l_asset_instance_number	VARCHAR2(30);
	l_instance_id			NUMBER;

	l_asset_ops_msg_count	        NUMBER;
	l_asset_ops_msg_data		VARCHAR2(2000);
	l_asset_ops_return_status	VARCHAR2(1);
	l_eam_location_id		NUMBER;
	l_department_id			NUMBER;
  i_status_type			NUMBER; --for 7305904
	l_comments_exists         VARCHAR2(1);

	l_wo_last_update_date1      DATE;  -- for FP bug of 10147896
	l_wo_last_update_date2      DATE;  -- for FP bug of 10147896

	-- BUG 12914431 begin
    TYPE plan_id_tbl     is TABLE OF number INDEX BY BINARY_INTEGER;
	TYPE plan_name_tbl   is TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
	l_plan_id_tbl	      plan_id_tbl;
	l_plan_name_tbl	      plan_name_tbl;
    -- BUG 12914431 end

	CURSOR cur_work_order_details IS
	SELECT  cii.inventory_item_id,
	        cii.instance_number,
		cii.instance_id,
		cii.serial_number,
		wdj.primary_item_id,
		wdj.maintenance_object_type,
		wdj.maintenance_object_id,
		wdj.maintenance_object_source,
                NVL(ewod.pending_flag,'N'),
		ewod.user_defined_status_id,
		wdj.status_type,
		ewod.workflow_type,
		eam_linear_location_id,
		owning_department
	  FROM  wip_discrete_jobs wdj,csi_item_instances cii,eam_work_order_details ewod
	 WHERE  wdj.wip_entity_id = l_eam_wo_comp_rec.wip_entity_id
	   AND  wdj.maintenance_object_type = 3
	   AND  wdj.maintenance_object_id = cii.instance_id
	   AND  wdj.wip_entity_id = ewod.wip_entity_id(+)
	 UNION
        SELECT  wdj.maintenance_object_id,
		null,
		null,
		null,
		wdj.primary_item_id,
		wdj.maintenance_object_type,
		wdj.maintenance_object_id,
		wdj.maintenance_object_source,
                NVL(ewod.pending_flag,'N'),
		ewod.user_defined_status_id,
		wdj.status_type,
		ewod.workflow_type,
		eam_linear_location_id,
		owning_department
	  FROM  wip_discrete_jobs wdj,eam_work_order_details ewod
	 WHERE  wdj.wip_entity_id = l_eam_wo_comp_rec.wip_entity_id
	   AND  wdj.maintenance_object_type = 2
	   AND  wdj.wip_entity_id = ewod.wip_entity_id(+);

	   l_eam_failure_entry_record Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ;
       l_eam_failure_codes_tbl Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;

       x_out_eam_failure_entry_record Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ;
      x_out_eam_failure_codes_tbl    Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ;



BEGIN
		 SAVEPOINT sv_wo_compl ;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.COMP_UNCOMP_WORKORDER Start ================================================');  END IF;

		 l_eam_failure_entry_record := p_eam_wo_comp_rec.eam_failure_entry_record;
	         l_eam_failure_codes_tbl    := p_eam_wo_comp_rec.eam_failure_codes_tbl;

		x_return_status		     := FND_API.G_RET_STS_SUCCESS;
	        l_eam_wo_comp_rec            := p_eam_wo_comp_rec;

		SELECT wip_entity_name INTO l_wip_entity_name
		  FROM wip_entities
		 WHERE wip_entity_id = l_eam_wo_comp_rec.wip_entity_id;

		l_org_id		:= l_eam_wo_comp_rec.organization_id;
		l_wip_entity_id		:= l_eam_wo_comp_rec.wip_entity_id;

		-- for FP bug of bug# 10147896, Capturing WO last_update_date at starting of COMP_UNCOMP_WORKORDER procedure.
		SELECT last_update_date INTO l_wo_last_update_date1 FROM wip_discrete_jobs WHERE wip_entity_id = l_wip_entity_id FOR UPDATE;

		 OPEN cur_work_order_details;

		 FETCH cur_work_order_details INTO
		       l_asset_group_id,
		       l_instance_number,
		       l_instance_id,
		       l_asset_number,
		       l_asset_activity_id,
		       l_maint_object_type,
		       l_maint_object_id,
		       l_maint_obj_source,
		       l_pending_flag,
		       l_old_eam_status,
		       l_old_system_status,
		       l_workflow_type,
		       l_eam_location_id,
		       l_department_id;

		CLOSE cur_work_order_details;

		SELECT msi.concatenated_segments
		   INTO l_asset_group_name
	           FROM mtl_system_items_kfv msi
		  WHERE msi.inventory_item_id = l_asset_group_id
		   AND rownum = 1;

		Begin
	  	  SELECT msi.concatenated_segments
		   INTO l_asset_activity
	           FROM mtl_system_items_kfv msi
		  WHERE msi.inventory_item_id = l_asset_activity_id
		   AND rownum = 1;
	        Exception
		  When NO_DATA_FOUND Then
		    l_asset_activity := null;
		End;

		l_workflow_enabled := Is_Workflow_Enabled(l_maint_obj_source, l_eam_wo_comp_rec.organization_id);
		l_status_changed_event := 'oracle.apps.eam.workorder.status.changed';
		l_status_pending_event := 'oracle.apps.eam.workorder.status.change.pending';

	        IF(l_eam_wo_comp_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_COMPLETE) THEN
		    l_new_system_status  := 4;           --can be complete/complete-no-charges...get from completion record
		    l_new_eam_status   := 4;         --get value from completion record
	        ELSE
		    l_new_system_status := 3;
		    l_new_eam_status := 3;
	        END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion: Transaction Type Validity . . . ');  END IF;

		VALIDATE_TRANSACTION_TYPE
		(   p_transaction_type  => l_eam_wo_comp_rec.transaction_type
		,   p_entity_name       => 'WORK_ORDER_COMPLETEION'
		,   p_entity_id         => l_eam_wo_comp_rec.wip_entity_id
		,   x_valid_transaction => l_valid_transaction
		,   x_mesg_token_tbl    => l_Mesg_Token_Tbl
		);

		IF NOT l_valid_transaction
		THEN
		    l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		    l_other_message := 'EAM_WOCMPL_INV_TXN_TYPE';
		    l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_other_token_tbl(1).token_value := l_wip_entity_name;

		    RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM WO Completeion:  Populate Null Columns . . .'); END IF;

		EAM_WO_COMP_DEFAULT_PVT.Populate_NULL_Columns
		(   p_eam_wo_comp_rec         => p_eam_wo_comp_rec
		,   x_eam_wo_comp_rec         => l_eam_wo_comp_rec
		,   x_return_status           => l_return_status
		);

		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
		THEN
			l_other_message := 'EAM_WOCMPL_POPULATE_NULL';
			l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			l_other_token_tbl(1).token_value := l_wip_entity_name;
			RAISE EXC_SEV_QUIT_RECORD;

		END IF;


		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('WO Completeion : Check Attributes b4 Defaulting . . .'); END IF;
		EAM_WO_COMP_VALIDATE_PVT.Check_Attributes_b4_Defaulting
		 ( p_eam_wo_comp_rec            => l_eam_wo_comp_rec
		 , x_mesg_token_tbl             => l_mesg_token_tbl
		 , x_return_status              => l_return_status
		 ) ;


		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
		THEN
			l_other_message := 'EAM_WOCMPL_CHK_ATTR_DEF';
			l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			l_other_token_tbl(1).token_value := l_wip_entity_name;
			RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('WO Completeion : Check Required . . .'); END IF;
		EAM_WO_COMP_VALIDATE_PVT.Check_Required
		 ( p_eam_wo_comp_rec            => l_eam_wo_comp_rec
		 , x_return_status              => l_return_status
		 , x_mesg_token_tbl             => l_mesg_token_tbl
		 ) ;
		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
		THEN
			l_other_message := 'EAM_WOCMPL_CHK_REQUIRED';
			l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			l_other_token_tbl(1).token_value := l_wip_entity_name;
			RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('WO Completeion Header: Check Attributes . . .'); END IF;

		EAM_WO_COMP_VALIDATE_PVT.Check_Attributes
		    (
			p_eam_wo_comp_rec          => l_eam_wo_comp_rec
		    ,   x_eam_wo_comp_rec          => l_eam_out_wo_comp_rec
		    ,   x_return_status            => l_return_status
		    ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
		    );

		l_eam_wo_comp_rec := l_eam_out_wo_comp_rec;
		x_return_status := l_return_status;

		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
		THEN
			l_other_message := 'EAM_WOCMPL_CHK_ATTR';
			l_other_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
			l_other_token_tbl(1).token_value := l_wip_entity_name;
			RAISE EXC_SEV_QUIT_RECORD;
		END IF;


	IF(l_workflow_enabled='Y'  AND    l_eam_wo_comp_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE
	                  AND (WF_EVENT.TEST(l_status_pending_event) <> 'NONE') )THEN
		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking WF Approval mandatory . . . ');  END IF;
							 EAM_WORKFLOW_DETAILS_PUB.Eam_Wf_Is_Approval_Required(p_old_wo_rec =>  NULL,
															   p_new_wo_rec  =>  NULL,
															    p_wip_entity_id        =>    l_eam_wo_comp_rec.wip_entity_id,
															    p_new_system_status  =>  l_new_system_status,
															    p_new_wo_status           =>  l_new_eam_status,
															    p_old_system_status     =>   l_old_system_status,
															    p_old_wo_status             =>   l_old_eam_status,
															   x_approval_required  =>  l_approval_required,
															   x_workflow_name   =>   l_workflow_name,
															   x_workflow_process    =>   l_workflow_process
															   );

						IF(l_approval_required) THEN
								   UPDATE EAM_WORK_ORDER_DETAILS
								   SET user_defined_status_id=3,
									    pending_flag='Y',
									    last_update_date=SYSDATE,
									    last_update_login=FND_GLOBAL.login_id,
									    last_updated_by=FND_GLOBAL.user_id
								   WHERE wip_entity_id= l_eam_wo_comp_rec.wip_entity_id;



                                                            --Find the total estimated cost of workorder
											   BEGIN
												 SELECT NVL((SUM(system_estimated_mat_cost) + SUM(system_estimated_lab_cost) + SUM(system_estimated_eqp_cost)),0)
												 INTO l_cost_estimate
												 FROM WIP_EAM_PERIOD_BALANCES
												 WHERE wip_entity_id = l_eam_wo_comp_rec.wip_entity_id;
											   EXCEPTION
											      WHEN NO_DATA_FOUND THEN
												  l_cost_estimate := 0;
											   END;


										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_pending_event;

										    l_event_key := TO_CHAR(l_wf_event_seq);


		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inserting into EAM_WO_WORKFLOWS ...');  END IF;
										     INSERT INTO EAM_WO_WORKFLOWS
										     (WIP_ENTITY_ID,WF_ITEM_TYPE,WF_ITEM_KEY,LAST_UPDATE_DATE,LAST_UPDATED_BY,
										     CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN)
										     VALUES
										     (l_eam_wo_comp_rec.wip_entity_id,l_workflow_name,l_event_key,SYSDATE,FND_GLOBAL.user_id,
										     SYSDATE,FND_GLOBAL.user_id,FND_GLOBAL.login_id
										     );


										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Released change event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(l_eam_wo_comp_rec.wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>l_wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(l_eam_wo_comp_rec.organization_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value =>TO_CHAR(l_new_eam_status) ,
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(l_old_system_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
													    p_value => TO_CHAR(l_old_eam_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(l_new_system_status),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(l_workflow_type),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_NAME',
													    p_value => l_workflow_name,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_PROCESS',
													    p_value => l_workflow_process,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'ESTIMATED_COST',
													    p_value => TO_CHAR(l_cost_estimate),
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Released Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Released Event','After raising event');


										   IF(l_maint_obj_source =1 ) THEN     --modify intermedia index only for EAM workorders
		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling intermedia procedure from WO API ...');  END IF;
													     EAM_TEXT_UTIL.PROCESS_WO_EVENT
													     (
														  p_event  => 'UPDATE',
														  p_wip_entity_id =>l_eam_wo_comp_rec.wip_entity_id,
														  p_organization_id =>l_eam_wo_comp_rec.organization_id,
														  p_last_update_date  => SYSDATE,
														  p_last_updated_by  => FND_GLOBAL.user_id,
														  p_last_update_login =>FND_GLOBAL.login_id
													     );
										   END IF;   --end of check for maint. obj. source

                                                          RETURN;
						END IF;
       END IF; -- end of check for workflow enabled


		--Invoke Update_Pm_When_Uncomplete to reverse last service dates and last service reading if this is the last work order
		--This should be called before Perform_Writes as the logic to calculate if this is the last work order or not will not work if record
		-- will be inserted into Eam_Job_Completion_Txns for uncompletion transaction.
		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE THEN
			   if( l_maint_obj_source = 1) then -- added to check whether work order is of 'EAM' or 'CRMO'.'EAM=1'
			           eam_pm_utils.update_pm_when_uncomplete(l_eam_wo_comp_rec.organization_id, l_eam_wo_comp_rec.wip_entity_id);
			   end if; -- end of source entity check
		END IF;

	-- for FP bug of bug# 10147896, Capturing WO last_update_date just before Writing WO Completion record to database .
		SELECT last_update_date INTO l_wo_last_update_date2  FROM wip_discrete_jobs WHERE wip_entity_id = l_wip_entity_id FOR UPDATE;

	 IF  l_wo_last_update_date1 <> l_wo_last_update_date2
		  THEN
		l_other_message := 'EAM_WO_COMP_WRONG_STATUS';
		l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		l_other_token_tbl(1).token_value := l_wip_entity_name;
		 RAISE EXC_SEV_QUIT_RECORD;
	 END IF;
	--end for FP bug of bug# 10147896.

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing WO Completion record to database ...');  END IF;
		 EAM_WO_COMP_UTILITY_PVT.PERFORM_WRITES
		(      p_eam_wo_comp_rec       => l_eam_wo_comp_rec
		    ,   x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
		    ,   x_return_status         => l_return_status
		 );

		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
		THEN
		    l_other_message := 'EAM_WOCMPL_WRITES_UNEXP_SKIP';
		    l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_other_token_tbl(1).token_value := l_wip_entity_name;
		    RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling WO Completion update_row ...');  END IF;

		 EAM_WO_COMP_UTILITY_PVT.update_row
		(   p_eam_wo_comp_rec       => l_eam_wo_comp_rec
		,   x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
		,   x_return_status         => l_return_status
		 );

		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
		THEN
		    l_other_message := 'EAM_WOCMPL_WRITES_UNEXP_SKIP';
		    l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_other_token_tbl(1).token_value := l_wip_entity_name;
		    RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF p_eam_wo_quality_tbl.COUNT > 0 AND l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing quality records...') ; END IF ;

		    FOR I IN l_eam_wo_quality_tbl.FIRST..l_eam_wo_quality_tbl.LAST LOOP
		      BEGIN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

				l_eam_wo_quality_rec := l_eam_wo_quality_tbl(I);
				colllection_id_temp := l_eam_wo_quality_rec.collection_id;

				VALIDATE_TRANSACTION_TYPE
				(   p_transaction_type  => l_eam_wo_quality_rec.transaction_type
				,   p_entity_name       => 'QUALITY_ENTRY'
				,   p_entity_id         => to_char(l_eam_wo_quality_rec.plan_id)
				,   X_valid_transaction => l_valid_transaction
				,   x_mesg_token_tbl    => l_mesg_token_tbl
				);

				IF NOT l_valid_transaction
				 THEN
					l_other_message := 'EAM_WOCMP_QA_INV_TXN';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;

				     l_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
				     RAISE EXC_SEV_QUIT_RECORD;
				 END IF ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quality : Check_Required...') ; END IF ;

				 EAM_WO_QUA_VALIDATE_PVT.Check_Required
				 (
					p_eam_wo_quality_rec => l_eam_wo_quality_rec
					, x_return_status    => l_return_status
					, x_mesg_token_tbl   => l_mesg_token_tbl
				 );

				 IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR THEN
					l_other_message := 'EAM_WOCMP_QA_CHK_REQ';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
				 END IF;

                     EXCEPTION

		     WHEN EXC_SEV_SKIP_BRANCH THEN

			l_out_eam_wo_quality_tbl	:= l_eam_wo_quality_tbl;
			EAM_ERROR_MESSAGE_PVT.Log_Error
		         (
				p_eam_wo_quality_tbl		=>	l_eam_wo_quality_tbl

			     , x_eam_wo_comp_rec		=>	l_out_eam_wo_comp_rec
			     , x_eam_wo_quality_tbl		=>	l_out_eam_wo_quality_tbl
			     , x_eam_meter_reading_tbl		=>	l_out_eam_meter_reading_tbl
			     , x_eam_counter_prop_tbl		=>      l_out_eam_counter_prop_tbl
			     , x_eam_wo_comp_rebuild_tbl	=>	l_out_eam_wo_comp_rebuild_tbl
			     , x_eam_wo_comp_mr_read_tbl	=>	l_out_eam_wo_comp_mr_read_tbl
			     , x_eam_op_comp_tbl		=>	l_out_eam_op_comp_tbl
			     , x_eam_request_tbl		=>	l_out_eam_request_tbl

			     , p_mesg_token_tbl			=>	l_mesg_token_tbl
			     , p_error_status			=>	FND_API.G_RET_STS_ERROR
			     , p_error_scope			=>	EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
			     , p_other_message			=>	l_other_message
			     , p_other_status			=>	EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
			     , p_other_token_tbl		=>	l_other_token_tbl

			     , p_error_level			=>	EAM_ERROR_MESSAGE_PVT.G_WO_COMP_LEVEL
		         );

				l_eam_wo_quality_tbl		:= l_out_eam_wo_quality_tbl;

				l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

				 x_eam_wo_quality_tbl		:=	l_eam_wo_quality_tbl;
				 x_return_status          	:=	l_return_status;
				 x_msg_count              	:=	l_msg_count;

	              END ;

		      IF l_return_status in ('Q', 'U','E')
			   THEN
			      x_return_status := l_return_status;
			      RETURN ;
		      END IF;

                    END LOOP;  -- End loop for p_eam_wo_quality_tbl.count > 0


	            BEGIN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quality : Insert_Row...') ; END IF ;

			 EAM_WO_QUA_UTILITY_PVT.insert_row
			   (
				   p_collection_id	=> colllection_id_temp
				 , p_eam_wo_quality_tbl  => p_eam_wo_quality_tbl
				 , x_eam_wo_quality_tbl  => l_eam_wo_quality_tbl
				 , x_return_status       => l_return_status
				 , x_mesg_token_tbl      => l_mesg_token_tbl
			   );
			 IF l_return_status  <> 'S' THEN
					l_other_message := 'EAM_WOCMP_QA_INSERT_REC';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			 END IF;
	            EXCEPTION
		       WHEN EXC_SEV_QUIT_RECORD THEN
				l_out_eam_wo_quality_tbl	:= l_eam_wo_quality_tbl;

				EAM_ERROR_MESSAGE_PVT.Log_Error
				 (
					p_eam_wo_quality_tbl		=>	l_eam_wo_quality_tbl

				     , x_eam_wo_comp_rec		=>	l_out_eam_wo_comp_rec
				     , x_eam_wo_quality_tbl		=>	l_out_eam_wo_quality_tbl
				     , x_eam_meter_reading_tbl		=>	l_out_eam_meter_reading_tbl
				     , x_eam_counter_prop_tbl		=>      l_out_eam_counter_prop_tbl
				     , x_eam_wo_comp_rebuild_tbl	=>	l_out_eam_wo_comp_rebuild_tbl
				     , x_eam_wo_comp_mr_read_tbl	=>	l_out_eam_wo_comp_mr_read_tbl
				     , x_eam_op_comp_tbl		=>	l_out_eam_op_comp_tbl
				     , x_eam_request_tbl		=>	l_out_eam_request_tbl

				     , p_mesg_token_tbl			=>	l_mesg_token_tbl
				     , p_error_status			=>	FND_API.G_RET_STS_ERROR
				     , p_error_scope			=>	EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
				     , p_other_message			=>	l_other_message
				     , p_other_status			=>	EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
				     , p_other_token_tbl		=>	l_other_token_tbl

				     , p_error_level			=>	EAM_ERROR_MESSAGE_PVT.G_WO_COMP_LEVEL
			       );

				l_eam_wo_quality_tbl		:= l_out_eam_wo_quality_tbl;

				l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

				 x_eam_wo_quality_tbl		:=	l_eam_wo_quality_tbl;
				 x_return_status          	:=	l_return_status;
				 x_msg_count              	:=	l_msg_count;
	            END ; -- END For Quality Insert row

	        END IF; -- END FOR Quality records.COUNT > 0

		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
			BEGIN

			IF l_asset_number IS NOT NULL THEN

				SELECT  cii.instance_number,cii.instance_id
				  into l_asset_instance_number,
				  l_asset_instance_id
				  FROM  wip_discrete_jobs wdj,csi_item_instances cii
				 WHERE  wdj.wip_entity_id = l_eam_wo_comp_rec.wip_entity_id
				   AND  wdj.maintenance_object_type = 3
				   AND  wdj.maintenance_object_id = cii.instance_id
				   AND  cii.serial_number = l_asset_number;
			END IF;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug('Quality : Checking whether mandatory quality plans remain...') ; END IF ;
				mandatory_qua_plan :=qa_web_txn_api.quality_mandatory_plans_remain(
					p_txn_number       => 31 ,
					p_organization_id  => l_org_id ,
					pk1                => l_asset_group_name ,    -- Asset Grp
					pk2                => l_asset_number  ,    -- Asset no
					pk3                => l_asset_activity  ,    -- Asset Act
					pk4                => l_wip_entity_name  ,    -- Work ordrr name
				--	pk5		   => l_eam_op_comp_rec.operation_seq_num ,
					pk6		   => l_asset_instance_number ,
					p_wip_entity_id    => l_wip_entity_id  ,     -- work order id
					p_collection_id    => l_eam_wo_comp_rec.qa_collection_id
				 );

				IF mandatory_qua_plan = 'Y' THEN

					l_other_message := 'EAM_WOCMPL_MAND_PLAN';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;

					l_return_status := FND_API.G_RET_STS_ERROR;

					RAISE EXC_SEV_QUIT_RECORD;

				    /* l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				    l_token_tbl(1).token_value :=  l_wip_entity_name;

				    l_out_mesg_token_tbl  := l_mesg_token_tbl;

				    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				    (  p_message_name	=> 'EAM_WOCMPL_MAND_PLAN'
				     , p_token_tbl	=> l_Token_tbl
				     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
				     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
				     );

				    x_return_status := FND_API.G_RET_STS_ERROR;

				   raise EXC_SEV_QUIT_RECORD; */

				END IF;
			END;
		END IF;
		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  THEN
		 /* Failure Analysis Project Start */
	         --Failure Entry data to be processed at work order completion
                 --For Normal EAM Work Orders and Serialized rebuildable work orders

       IF (    l_asset_number   IS NOT NULL
          ) THEN

          l_comments_exists := 'N';

          FOR i in 1..l_eam_failure_codes_tbl.count
          LOOP

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing failure entry records...') ; END IF ;

            IF l_eam_failure_codes_tbl(i).comments IS NOT NULL THEN
               l_comments_exists := 'Y';
            END IF;

            l_eam_failure_codes_tbl(i).failure_id      := l_eam_failure_entry_record.failure_id;
            IF l_eam_failure_codes_tbl(i).failure_entry_id IS NULL THEN
               l_eam_failure_codes_tbl(i).transaction_type:= Eam_Process_Failure_Entry_PUB.G_FE_CREATE;
            ELSE
               l_eam_failure_codes_tbl(i).transaction_type:= Eam_Process_Failure_Entry_PUB.G_FE_UPDATE;
            END IF;

            IF (    l_eam_failure_codes_tbl(i).failure_entry_id IS NULL
                AND l_eam_failure_codes_tbl(i).failure_code IS NULL
                AND l_eam_failure_codes_tbl(i).cause_code IS NULL
                AND l_eam_failure_codes_tbl(i).resolution_code IS NULL
                AND l_eam_failure_codes_tbl(i).COMMENTS IS NULL
               )
            THEN
              l_eam_failure_codes_tbl.delete(i);
            END IF;
          END LOOP;

	  /* Failure Entry Project */
          IF (l_department_id IS NULL) THEN
	    BEGIN
                SELECT OWNING_DEPARTMENT_ID
                  INTO l_department_id
                  FROM eam_org_maint_defaults
                 WHERE object_id = l_maint_object_id
		   AND object_type = 60 AND organization_id = l_org_id ;
            EXCEPTION
	        WHEN NO_DATA_FOUND THEN
                    null;
            END;
          END IF;

	  /* Failure Entry Project */
          IF (l_eam_location_id IS NULL) THEN
	    BEGIN
                SELECT area_id
                  INTO l_eam_location_id
                  FROM eam_org_maint_defaults
                 WHERE object_id = l_maint_object_id
		   AND object_type = 60 AND organization_id = l_org_id ;
            EXCEPTION
	        WHEN NO_DATA_FOUND THEN
                    null;
            END;
          END IF;


             /* Failure Entry Project */

          IF (    l_eam_failure_entry_record.failure_id IS NULL
              AND (   l_comments_exists = 'Y'
                   OR l_eam_failure_entry_record.failure_date IS NOT NULL
                  )
             )
          THEN
             l_eam_failure_entry_record.transaction_type:= Eam_Process_Failure_Entry_PUB.G_FE_CREATE;
             l_eam_failure_entry_record.source_type             := 1;
             l_eam_failure_entry_record.source_id               := l_wip_entity_id;
             l_eam_failure_entry_record.object_type             := l_maint_object_type;
             l_eam_failure_entry_record.object_id               := l_maint_object_id;
             l_eam_failure_entry_record.maint_organization_id   := l_org_id;
             l_eam_failure_entry_record.current_organization_id := l_org_id;
             l_eam_failure_entry_record.department_id           := l_department_id;
             l_eam_failure_entry_record.area_id                 := l_eam_location_id;
          ELSIF l_eam_failure_entry_record.failure_id IS NOT NULL THEN
             l_eam_failure_entry_record.transaction_type := Eam_Process_Failure_Entry_PUB.G_FE_UPDATE;
             l_eam_failure_entry_record.maint_organization_id   := l_org_id;
             l_eam_failure_entry_record.current_organization_id := l_org_id;
             l_eam_failure_entry_record.department_id           := l_department_id;
             l_eam_failure_entry_record.area_id                 := l_eam_location_id;
          END IF;

          IF (   l_eam_failure_entry_record.failure_date IS NOT NULL
              OR l_comments_exists = 'Y'
              OR l_eam_failure_entry_record.failure_id IS NOT NULL
             )
          THEN
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling process_failure_entry procedure...') ; END IF ;
                  Eam_Process_Failure_Entry_PUB.process_failure_entry
                  (
                     p_eam_failure_entry_record     => l_eam_failure_entry_record
                   , p_eam_failure_codes_tbl        => l_eam_failure_codes_tbl
                   , x_return_status                => l_return_status
                   , x_msg_count                    => l_msg_count
                   , x_msg_data                     => l_msg_data
                   , x_eam_failure_entry_record     => l_eam_wo_comp_rec.eam_failure_entry_record
                   , x_eam_failure_codes_tbl        => l_eam_wo_comp_rec.eam_failure_codes_tbl
                  );

                  /* IF l_return_status <> 'S' THEN
                     errCode := 1;
                     errMsg := Fnd_Msg_Pub.Get(1,Fnd_Api.G_FALSE);
                     return;
                  END IF; */
		IF NVL(l_return_status, 'T') <> 'S' THEN
			l_return_status := 'E';
			RAISE EXC_SEV_QUIT_RECORD;
		END IF;

          END IF;

       END IF;
       /* Failure Analysis Project End */

      END IF;

		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  THEN

          -- BUG12914431 begin
            BEGIN

			select qp.plan_id,name bulk collect
			into  l_plan_id_tbl,l_plan_name_tbl
			from qa_results qr,qa_plans qp
			where qr.plan_id = qp.plan_id
			and collection_id = l_eam_wo_comp_rec.qa_collection_id;

            END;

          IF l_plan_id_tbl.Count > 0 THEN
          -- BUG12914431 end

		        BEGIN
			    contextStr := '162='||l_asset_group_id||'@163='
			    ||l_asset_number||'@2147483550='||l_asset_instance_id||'@165='||l_wip_entity_id
			    ||'@164='||l_asset_activity_id;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling post_background_results procedure...') ; END IF ;
			    qa_web_txn_api.post_background_results(
				p_txn_number         =>  31 ,
				p_org_id             => l_org_id  ,
				p_context_values     => contextStr ,
				p_collection_id      => l_eam_wo_comp_rec.qa_collection_id
			    );
		        EXCEPTION WHEN OTHERS THEN
			    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			    l_token_tbl(1).token_value :=  l_wip_entity_name;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;

			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_WO_CMPL_BACK_ERR'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );

			    x_return_status := FND_API.G_RET_STS_ERROR;

			   RAISE EXC_SEV_QUIT_RECORD;
		        END ;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling enable_and_fire_action procedure...') ; END IF ;

			qa_result_grp.enable_and_fire_action(
			 p_api_version         => 1.0  ,
			 p_collection_id       => l_eam_wo_comp_rec.qa_collection_id   ,
			 x_return_status       => l_return_status  ,
			 x_msg_count           => l_msg_count   ,
			 x_msg_data            => l_msg_data
		         );

			IF l_return_status = 'Y' THEN
			    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			    l_token_tbl(1).token_value :=  l_wip_entity_name;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;

			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_WOCMPL_QUALITY_COMMMIT'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );

			    x_return_status := FND_API.G_RET_STS_ERROR;

			   RAISE EXC_SEV_QUIT_RECORD;
			END IF;
          END IF; -- l_plan_id_tbl.count > 0 -- BUG 12914431
		END IF; -- end if for p_eam_wo_quality_tbl.COUNT > 0

		--bug 8591423

		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  and p_eam_meter_reading_tbl.COUNT > 0 THEN
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_VALIDATE_PVT.insert_row procedure...') ; END IF ;
			EAM_METERREADING_UTILITY_PVT.INSERT_ROW
			(
				 p_eam_meter_reading_tbl  => p_eam_meter_reading_tbl
				, p_eam_counter_prop_tbl  => p_eam_counter_prop_tbl
				, x_eam_meter_reading_tbl => x_eam_meter_reading_tbl
				, x_eam_counter_prop_tbl  => x_eam_counter_prop_tbl
				, x_return_status         => l_return_status
				, x_mesg_token_tbl	  => l_mesg_token_tbl
			);

			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_METER_ENTER';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;

		END IF;

		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE and l_maint_object_type =3  THEN
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_VALIDATE_PVT.MANDATORY_ENTERED procedure...') ; END IF ;
		   EAM_METERREADING_VALIDATE_PVT.MANDATORY_ENTERED
			(
			     p_wip_entity_id 		=> l_eam_wo_comp_rec.wip_entity_id
			   , p_instance_id		=> l_maint_object_id
			   , p_eam_meter_reading_tbl    => p_eam_meter_reading_tbl
			   , p_work_order_cmpl_date     => l_eam_wo_comp_rec.actual_end_date
			   , x_return_status            => l_return_status
			   , x_man_reading_enter        => l_man_reading_enter
			);

			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_MAN_METER_ENTER';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;
		END IF;



		/* Bug # 5255459 : call DISABLE_COUNTER_HIERARCHY every time */

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_UTILITY_PVT.DISABLE_COUNTER_HIERARCHY procedure...') ; END IF ;
		EAM_METERREADING_UTILITY_PVT.DISABLE_COUNTER_HIERARCHY
		(
			p_eam_wo_comp_rebuild_tbl => p_eam_wo_comp_rebuild_tbl ,
			p_subinventory_id	  => l_eam_wo_comp_rec.completion_subinventory ,
			p_wip_entity_id           => l_eam_wo_comp_rec.wip_entity_id,
			x_eam_wo_comp_rebuild_tbl => x_eam_wo_comp_rebuild_tbl ,
			x_return_status           => l_return_status ,
			x_mesg_token_tbl	  => l_mesg_token_tbl
		);
		IF l_return_status <> 'S' THEN
			l_other_message := 'EAM_WOCMPL_DIS_COUNTER_HIER';
			l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			l_other_token_tbl(1).token_value := l_wip_entity_name;
			RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF p_eam_wo_comp_rebuild_tbl.COUNT > 0 THEN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling AM_METERREADING_UTILITY_PVT.Update_Genealogy procedure...') ; END IF ;
			EAM_METERREADING_UTILITY_PVT.UPDATE_GENEALOGY
			(
				p_eam_wo_comp_rebuild_tbl => p_eam_wo_comp_rebuild_tbl ,
				x_eam_wo_comp_rebuild_tbl => x_eam_wo_comp_rebuild_tbl ,
				x_return_status           => l_return_status ,
				x_mesg_token_tbl	  => l_mesg_token_tbl
			);

			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_UPDATE_GEN';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling AM_METERREADING_UTILITY_PVT.UPDATE_REBUILD_WORK_ORDER procedure...') ; END IF ;
			EAM_METERREADING_UTILITY_PVT.UPDATE_REBUILD_WORK_ORDER
			(
				p_eam_wo_comp_rebuild_tbl => p_eam_wo_comp_rebuild_tbl ,
				x_eam_wo_comp_rebuild_tbl => x_eam_wo_comp_rebuild_tbl ,
				x_return_status           => l_return_status ,
				x_mesg_token_tbl	  => l_mesg_token_tbl
			);
			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_UPDATE_WORK';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;


			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_UTILITY_PVT.UPDATE_ACTIVITY procedure...') ; END IF ;
			EAM_METERREADING_UTILITY_PVT.UPDATE_ACTIVITY
			(
				p_eam_wo_comp_rebuild_tbl => p_eam_wo_comp_rebuild_tbl ,
				x_eam_wo_comp_rebuild_tbl => x_eam_wo_comp_rebuild_tbl ,
				x_return_status           => l_return_status ,
				x_mesg_token_tbl	  => l_mesg_token_tbl
			);
			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_UPDATE_ACT';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;

		END IF;

		IF p_eam_wo_comp_mr_read_tbl.COUNT > 0 THEN
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_UTILITY_PVT.ENABLE_SOURCE_METER procedure...') ; END IF ;
			EAM_METERREADING_UTILITY_PVT.ENABLE_SOURCE_METER
			(
				p_eam_wo_comp_mr_read_tbl => p_eam_wo_comp_mr_read_tbl ,
				x_eam_wo_comp_mr_read_tbl => x_eam_wo_comp_mr_read_tbl ,
				x_return_status           => l_return_status ,
				x_mesg_token_tbl	  => l_mesg_token_tbl
			);
			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_ENABLE_COUNTER_HIER';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;
		END IF;

		/* -- For work order completeion call Eam_Meters_util. Update_Last_Service_Reading_Dates

		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  AND	p_eam_meter_reading_tbl.COUNT > 0 THEN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_UTILITY_PVT.UPDATE_LAST_SERVICE_READING procedure...') ; END IF ;
			EAM_METERREADING_UTILITY_PVT.UPDATE_LAST_SERVICE_READING
			(
			   p_eam_meter_reading_tbl   => p_eam_meter_reading_tbl
			 , x_eam_meter_reading_tbl   => x_eam_meter_reading_tbl
			 , x_return_status           => l_return_status
			 , x_mesg_token_tbl          => l_mesg_token_tbl
			);
			IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_LAST_SER_READ';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;
		END IF; */

	IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE AND
	   l_eam_wo_comp_rec.completion_subinventory IS NULL THEN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling csi_eam_interface_grp.wip_completion procedure...') ; END IF ;
		csi_eam_interface_grp.wip_completion
		 (
			 p_wip_entity_id   => l_eam_wo_comp_rec.wip_entity_id,
			 p_organization_id => l_eam_wo_comp_rec.organization_id,
			 x_return_status   => l_return_status,
			 x_error_message   => l_error_message
		 );

		 IF l_return_status <> 'S' THEN
					l_other_message := 'EAM_WOCMPL_IB_WIP_CMPL';
					l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_other_token_tbl(1).token_value := l_wip_entity_name;
					RAISE EXC_SEV_QUIT_RECORD;
		END IF;
	END IF;

	IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
		declare

			TYPE plan_id_tbl     is TABLE OF number INDEX BY BINARY_INTEGER;
			TYPE plan_name_tbl   is TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
			--l_plan_id_tbl	     plan_id_tbl;
			--l_plan_name_tbl	 plan_name_tbl;
			l_asset_ops_msg_count	  NUMBER;
			l_asset_ops_msg_data	  VARCHAR2(2000);
			l_asset_ops_return_status VARCHAR2(1);
		begin
           --BUG12914431. commented below code and moved it above
           /*
			select qp.plan_id,name bulk collect into l_plan_id_tbl,l_plan_name_tbl
			from qa_results qr,qa_plans qp
			where qr.plan_id = qp.plan_id
			and collection_id = l_eam_wo_comp_rec.qa_collection_id;
           */
			IF l_plan_id_tbl.COUNT  > 0 THEN
				FOR N IN l_plan_id_tbl.FIRST..l_plan_id_tbl.LAST LOOP
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_ASSET_LOG_PVT.INSERT_ROW procedure...') ; END IF ;
					EAM_ASSET_LOG_PVT.INSERT_ROW
					 (
						p_api_version		=> 1.0,
						p_event_date		=> sysdate,
						p_event_type		=> 'EAM_SYSTEM_EVENTS',
						p_event_id		=> 12,
						p_organization_id	=> l_eam_wo_comp_rec.organization_id,
						p_instance_id		=> l_maint_object_id,
						p_comments		=> null,
						p_reference		=> l_plan_name_tbl(N),
						p_ref_id		=> l_plan_id_tbl(N),
						p_operable_flag		=> null,
						p_reason_code		=> null,
						x_return_status		=> l_asset_ops_return_status,
						x_msg_count		=> l_asset_ops_msg_count,
						x_msg_data		=> l_asset_ops_msg_data
					 );
				END LOOP;
			END IF;

		end;
	END IF;
	--Raise status changed event when a workorder is completed/uncompleted

	                 IF(l_workflow_enabled='Y'  AND (WF_EVENT.TEST(l_status_changed_event) <> 'NONE')  --if status change event enabled
					) THEN

										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();
										      l_event_name := l_status_changed_event;

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Status change event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(l_eam_wo_comp_rec.wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>l_wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(l_eam_wo_comp_rec.organization_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
													    p_value => TO_CHAR(l_new_system_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
													    p_value => TO_CHAR(l_new_eam_status),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
													    p_value => TO_CHAR(l_old_system_status),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
													    p_value => TO_CHAR(l_old_eam_status),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(l_workflow_type),
													    p_parameterlist => l_parameter_list);
										      Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);
										    Wf_Core.Context('Enterprise Asset Management...','Work Order Staus Changed Event','Raising event');

										    Wf_Event.Raise(	p_event_name => l_event_name,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										     WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Status Changed Event','After raising event');
			END IF;   --end of check for status change event

										 IF(l_maint_obj_source =1 ) THEN     --modify intermedia index only for EAM workorders
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_TEXT_UTIL.PROCESS_WO_EVENT procedure...') ; END IF ;
													     EAM_TEXT_UTIL.PROCESS_WO_EVENT
													     (
														  p_event  => 'UPDATE',
														  p_wip_entity_id =>l_eam_wo_comp_rec.wip_entity_id,
														  p_organization_id =>l_eam_wo_comp_rec.organization_id,
														  p_last_update_date  => SYSDATE,
														  p_last_updated_by  => FND_GLOBAL.user_id,
														  p_last_update_login =>FND_GLOBAL.login_id
													     );
										END IF; --end of check for EAM workorders


		IF l_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_ASSET_LOG_PVT.INSERT_ROW procedure...') ; END IF ;
			 EAM_ASSET_LOG_PVT.INSERT_ROW
				 (
					p_api_version		=> 1.0,
					p_event_date		=> sysdate,
					p_event_type		=> 'EAM_SYSTEM_EVENTS',
					p_event_id		=> 8,
					p_organization_id	=> l_eam_wo_comp_rec.organization_id,
					p_instance_id		=> l_maint_object_id,
					p_comments		=> null,
					p_reference		=> l_wip_entity_name,
					p_ref_id		=> l_eam_wo_comp_rec.wip_entity_id,
					p_operable_flag		=> null,
					p_reason_code		=> null,
					x_return_status		=> l_asset_ops_return_status,
					x_msg_count		=> l_asset_ops_msg_count,
					x_msg_data		=> l_asset_ops_msg_data
				 );
		ELSE
			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_ASSET_LOG_PVT.INSERT_ROW procedure...') ; END IF ;
			 EAM_ASSET_LOG_PVT.INSERT_ROW
				 (
					p_api_version		=> 1.0,
					p_event_date		=> sysdate,
					p_event_type		=> 'EAM_SYSTEM_EVENTS',
					p_event_id		=> 9,
					p_organization_id	=> l_eam_wo_comp_rec.organization_id,
					p_instance_id		=> l_maint_object_id,
					p_comments		=> null,
					p_reference		=> l_wip_entity_name,
					p_ref_id		=> l_eam_wo_comp_rec.wip_entity_id,
					p_operable_flag		=> null,
					p_reason_code		=> null,
					x_return_status		=> l_asset_ops_return_status,
					x_msg_count		=> l_asset_ops_msg_count,
					x_msg_data		=> l_asset_ops_msg_data
				 );
		END IF;

		 x_eam_wo_comp_rec		:=	l_eam_wo_comp_rec;
		 x_eam_wo_quality_tbl		:=	l_eam_wo_quality_tbl;
		 x_eam_meter_reading_tbl  	:=	l_eam_meter_reading_tbl;
		 x_eam_counter_prop_tbl         :=      l_eam_counter_prop_tbl;
		 x_eam_wo_comp_rebuild_tbl	:=	l_eam_wo_comp_rebuild_tbl;
		 x_eam_wo_comp_mr_read_tbl	:=	l_eam_wo_comp_mr_read_tbl;

      -- Added for 7305904 RELIEVE ALLOCATIONS FOR COMPLETE NO CHARGE STATUS

     select system_status into i_status_type
	   from eam_wo_statuses_V
	   where status_id = p_eam_wo_comp_rec.user_status_id
	   and enabled_flag = 'Y';

    IF (i_status_type = 5) then -- added status 5 Complete - No Charges for bug 7305904 FP of 6348136
      IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling wip_picking_pub.cancel_allocations') ; END IF ;
      wip_picking_pub.cancel_allocations (p_wip_entity_id => l_wip_entity_id,
        p_wip_entity_type =>  wip_constants.eam,
        p_repetitive_schedule_id => NULL,
        x_return_status => l_return_status,
        x_msg_data => l_msg_data);
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('wip_picking_pub.cancel_allocations returned: x_return_status:' ||x_return_status) ; END IF ;
    end if;

       IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.COMP_UNCOMP_WORKORDER : End ==== Return status: '||l_return_status||' ======') ; END IF ;

	EXCEPTION -- Excepetion handler for begin

	    WHEN EXC_SEV_QUIT_RECORD THEN

	    rollback to sv_wo_compl;
		l_out_eam_wo_comp_rec           := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl	:= l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl	:= l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl      := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl	:= l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl	:= l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl		:= l_eam_op_comp_tbl;
		l_out_eam_request_tbl		:= l_eam_request_tbl;

	      EAM_ERROR_MESSAGE_PVT.Log_Error
	      (
	       p_eam_wo_comp_rec		=>	l_eam_wo_comp_rec
	     , p_eam_wo_quality_tbl		=>	l_eam_wo_quality_tbl
	     , p_eam_meter_reading_tbl		=>	l_eam_meter_reading_tbl
	     , p_eam_counter_prop_tbl		=>      l_eam_counter_prop_tbl
	     , p_eam_wo_comp_rebuild_tbl	=>	l_eam_wo_comp_rebuild_tbl
	     , p_eam_wo_comp_mr_read_tbl	=>	l_eam_wo_comp_mr_read_tbl
	     , p_eam_op_comp_tbl		=>	l_eam_op_comp_tbl
	     , p_eam_request_tbl		=>	l_eam_request_tbl

	     , x_eam_wo_comp_rec		=>	l_out_eam_wo_comp_rec
	     , x_eam_wo_quality_tbl		=>	l_out_eam_wo_quality_tbl
	     , x_eam_meter_reading_tbl		=>	l_out_eam_meter_reading_tbl
	     , x_eam_counter_prop_tbl		=>      l_out_eam_counter_prop_tbl
	     , x_eam_wo_comp_rebuild_tbl	=>	l_out_eam_wo_comp_rebuild_tbl
	     , x_eam_wo_comp_mr_read_tbl	=>	l_out_eam_wo_comp_mr_read_tbl
	     , x_eam_op_comp_tbl		=>	l_out_eam_op_comp_tbl
	     , x_eam_request_tbl		=>	l_out_eam_request_tbl

	     , p_mesg_token_tbl			=>	l_mesg_token_tbl
	     , p_error_status			=>	FND_API.G_RET_STS_ERROR
	     , p_error_scope			=>	EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
	     , p_other_message			=>	l_other_message
	     , p_other_status			=>	EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
	     , p_other_token_tbl		=>	l_other_token_tbl

	     , p_error_level			=>	EAM_ERROR_MESSAGE_PVT.G_WO_COMP_LEVEL
	     );

		l_eam_wo_comp_rec		:= l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl		:= l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl		:= l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl		:= l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl	:= l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl	:= l_out_eam_wo_comp_mr_read_tbl;

		l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

		 x_eam_wo_comp_rec		:=	l_eam_wo_comp_rec;
		 x_eam_wo_quality_tbl		:=	l_eam_wo_quality_tbl;
		 x_eam_meter_reading_tbl  	:=	l_eam_meter_reading_tbl;
		 x_eam_counter_prop_tbl         :=      l_eam_counter_prop_tbl;
		 x_eam_wo_comp_rebuild_tbl	:=	l_eam_wo_comp_rebuild_tbl;
		 x_eam_wo_comp_mr_read_tbl	:=	l_eam_wo_comp_mr_read_tbl;
		 x_return_status          	:=	l_return_status;
		 x_msg_count              	:=	l_msg_count;

		 RETURN;

 END COMP_UNCOMP_WORKORDER;















 PROCEDURE COMP_UNCOMP_OPERATION
	(
	  p_eam_op_compl_tbl	    IN EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, p_eam_wo_quality_tbl      IN EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_eam_op_comp_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, x_eam_wo_quality_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_return_status           OUT NOCOPY VARCHAR2
	, x_msg_count               OUT NOCOPY NUMBER
	)IS

	l_eam_op_comp_rec		EAM_PROCESS_WO_PUB.eam_op_comp_rec_type;
	l_eam_out_op_comp_rec		EAM_PROCESS_WO_PUB.eam_op_comp_rec_type;
	l_valid_transaction		BOOLEAN := TRUE ;
	l_mesg_token_tbl		EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_return_status			VARCHAR2(1);

	l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type	;
	l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type	;
	l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type ;
	l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type ;
	l_eam_counter_prop_tbl		EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type	;
	l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_out_eam_wo_comp_rec		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_counter_prop_tbl	EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_other_message			VARCHAR2(2000);
	l_other_token_tbl		EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
	l_token_tbl			EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
	l_msg_count			NUMBER;

	l_eam_wo_quality_temp_tbl       EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_wo_quality_rec            EAM_PROCESS_WO_PUB.eam_wo_quality_rec_type;
	colllection_id_temp		NUMBER;
	mandatory_qua_plan		VARCHAR2(1);
	l_org_id			NUMBER;
	l_asset_group_id		NUMBER;
	l_asset_number			VARCHAR2(30);
	l_asset_instance_id		NUMBER;
	l_asset_activity		VARCHAR2(240);
	l_asset_group_name		VARCHAR2(240);
	l_wip_entity_name		VARCHAR2(240);
	l_wip_entity_id			NUMBER;
	l_asset_activity_id		NUMBER;
	l_out_mesg_token_tbl		EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
	l_msg_data			VARCHAR2(2000);
	contextStr			VARCHAR2(2000);
	l_maint_obj_source		NUMBER;
	l_workflow_enabled		VARCHAR2(1);
	l_op_completed_event		VARCHAR2(240);
	l_workflow_type                 NUMBER;
	l_is_last_operation             VARCHAR2(1);
	l_parameter_list		wf_parameter_list_t;
	l_event_key			VARCHAR2(200);
	l_wf_event_seq			NUMBER;
	l_op_sched_end_date             DATE;
	l_asset_instance_number		VARCHAR2(30);

	BEGIN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.COMP_UNCOMP_OPERATION : Start==========================================================') ; END IF ;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status	:= FND_API.G_RET_STS_SUCCESS;

	l_eam_wo_quality_tbl	:= p_eam_wo_quality_tbl;
	l_eam_op_comp_rec	:= p_eam_op_compl_tbl(p_eam_op_compl_tbl.FIRST);
	l_org_id		:= l_eam_op_comp_rec.organization_id;
	l_wip_entity_id		:= l_eam_op_comp_rec.wip_entity_id;

	SELECT wip_entity_name INTO l_wip_entity_name
	  FROM wip_entities
	 WHERE wip_entity_id = l_eam_op_comp_rec.wip_entity_id;

	SELECT nvl(wdj.asset_group_id,wdj.rebuild_item_id),
	       nvl(wdj.asset_number,wdj.rebuild_serial_number),
	       wdj.primary_item_id,
	       wdj.maintenance_object_source,
               ewod.workflow_type
	  INTO l_asset_group_id,
	       l_asset_number,
	       l_asset_activity_id,
	       l_maint_obj_source,
	       l_workflow_type
          FROM wip_discrete_jobs wdj,eam_work_order_details ewod
	 WHERE wdj.wip_entity_id = l_eam_op_comp_rec.wip_entity_id
	   AND wdj.wip_entity_id = ewod.wip_entity_id(+);

	SELECT msi.concatenated_segments
	   INTO l_asset_group_name
           FROM mtl_system_items_kfv msi
	  WHERE msi.inventory_item_id = l_asset_group_id
	   AND rownum = 1;
	Begin
  	  SELECT msi.concatenated_segments
	   INTO l_asset_activity
           FROM mtl_system_items_kfv msi
	  WHERE msi.inventory_item_id = l_asset_activity_id
	   AND rownum = 1;

        Exception
	  When NO_DATA_FOUND Then
	    l_asset_activity := null;
	End;

	 l_workflow_enabled:= Is_Workflow_Enabled(l_maint_obj_source,l_org_id);
	 l_op_completed_event := 'oracle.apps.eam.workorder.operation.completed';

	FOR i IN p_eam_op_compl_tbl.FIRST..p_eam_op_compl_tbl.LAST LOOP
	BEGIN
		l_eam_op_comp_rec := p_eam_op_compl_tbl(i);
		l_org_id	  := l_eam_op_comp_rec.organization_id;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion: Transaction Type Validity . . . ');  END IF;

		VALIDATE_TRANSACTION_TYPE
		(   p_transaction_type  => l_eam_op_comp_rec.transaction_type
		,   p_entity_name       => 'OPERATION_COMPLETEION'
		,   p_entity_id         => l_eam_op_comp_rec.wip_entity_id
		,   x_valid_transaction => l_valid_transaction
		,   x_mesg_token_tbl    => l_Mesg_Token_Tbl
		);

		IF NOT l_valid_transaction
		THEN
		    x_eam_op_comp_tbl(i).return_status	:= EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		    l_other_message := 'EAM_OP_CMPL_INV_TXN';
		    l_other_token_tbl(1).token_name  := 'OP_SEQ';
		    l_other_token_tbl(1).token_value := l_eam_op_comp_rec.operation_seq_num ;
		    RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion : Check Required . . .'); END IF;

		EAM_OP_COMP_VALIDATE_PVT.Check_Required
		 ( p_eam_op_comp_rec            => l_eam_op_comp_rec
		 , x_return_status              => l_return_status
		 , x_mesg_token_tbl             => l_mesg_token_tbl
		 ) ;
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Order Completeion Check required completed with return_status: ' || l_return_status) ; END IF ;

	        IF l_return_status <> 'S'
		 THEN
 		       x_eam_op_comp_tbl(i).return_status	:= EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		       l_other_message := 'EAM_OP_CHKREQ_CSEV_SKIP';
		       l_other_token_tbl(1).token_name  := 'OP_SEQ';
		       l_other_token_tbl(1).token_value := l_eam_op_comp_rec.operation_seq_num ;
		       RAISE EXC_SEV_QUIT_RECORD ;
	        END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM Operation Completeion:  Populate Null Columns . . .'); END IF;
		l_eam_out_op_comp_rec := l_eam_op_comp_rec;
		EAM_OP_COMP_DEFAULT_PVT.Populate_NULL_Columns
			(   p_eam_op_comp_rec         => l_eam_op_comp_rec
			,   x_eam_op_comp_rec         => l_eam_out_op_comp_rec
			,   x_return_status           => l_return_status
		);
		l_eam_op_comp_rec := l_eam_out_op_comp_rec;

		IF l_return_status <> 'S'
		   THEN
		       x_eam_op_comp_tbl(i).return_status	:= EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		       l_other_message := 'EAM_OP_CMPL_POPULATE_NULL';
		       l_other_token_tbl(1).token_name  := 'OP_SEQ';
		       l_other_token_tbl(1).token_value := l_eam_op_comp_rec.operation_seq_num ;
			RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion : Check Attributes . . .'); END IF;
		EAM_OP_COMP_VALIDATE_PVT.Check_Attributes
		    (
			p_eam_op_comp_rec          => l_eam_op_comp_rec
		    ,   x_return_status            => l_return_status
		    ,   x_Mesg_Token_Tbl           => l_Mesg_Token_Tbl
		    );

		IF l_return_status <> 'S'
		THEN
		       x_eam_op_comp_tbl(i).return_status	:= EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		       l_other_message := 'EAM_OP_CHKATTR_CSEV_SKIP';
	               l_other_token_tbl(1).token_name  := 'OP_SEQ';
		       l_other_token_tbl(1).token_value := l_eam_op_comp_rec.operation_seq_num ;
	               RAISE EXC_SEV_QUIT_RECORD ;
		END IF;



		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion : Perform Writes . . .'); END IF;
		 EAM_OP_COMP_UTILITY_PVT.PERFORM_WRITES
		(   p_eam_op_comp_rec       => l_eam_op_comp_rec
	        ,   x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
	        ,   x_return_status         => l_return_status
	         );

		 IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
		 THEN
		       x_eam_op_comp_tbl(i).return_status	:= EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		       l_other_message := 'EAM_OP_CMPL_WRITE_REC';
		       l_other_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		       l_other_token_tbl(1).token_value := l_eam_op_comp_rec.operation_seq_num ;
		       RAISE EXC_SEV_QUIT_RECORD ;
		END IF;

		x_eam_op_comp_tbl(i) := l_eam_op_comp_rec;


		IF l_eam_wo_quality_tbl.COUNT > 0 AND l_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
			FOR J IN l_eam_wo_quality_tbl.FIRST..l_eam_wo_quality_tbl.LAST LOOP
				IF l_eam_wo_quality_tbl(j).operation_seq_number = p_eam_op_compl_tbl(i).operation_seq_num THEN
					l_eam_wo_quality_temp_tbl(j) := l_eam_wo_quality_tbl(j);
				END IF;
			END LOOP;

			 FOR K IN l_eam_wo_quality_temp_tbl.FIRST..l_eam_wo_quality_temp_tbl.LAST LOOP
			   BEGIN

				IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing '|| I || ' record') ; END IF ;

				--  Load local records.
				l_eam_wo_quality_rec := l_eam_wo_quality_temp_tbl(K);

				colllection_id_temp := l_eam_wo_quality_rec.collection_id;

				IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion validating Quality Record Transaction Type . . .'); END IF;

				VALIDATE_TRANSACTION_TYPE
				(   p_transaction_type  => l_eam_wo_quality_rec.transaction_type
				,   p_entity_name       => 'QUALITY_ENTRY'
				,   p_entity_id         => to_char(l_eam_wo_quality_rec.plan_id)
				,   X_valid_transaction => l_valid_transaction
				,   x_mesg_token_tbl    => l_mesg_token_tbl
				);

				IF NOT l_valid_transaction
				 THEN
					l_other_message := 'EAM_QA_INV_TXN';
					l_other_token_tbl(1).token_name  := 'OP_SEQ';
					l_other_token_tbl(1).token_value := l_eam_wo_quality_rec.operation_seq_number;
					RAISE EXC_SEV_QUIT_RECORD ;
				 END IF ;

				 IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion validating Quality Record Check Required . . .'); END IF;

				 EAM_WO_QUA_VALIDATE_PVT.Check_Required
				 (
					p_eam_wo_quality_rec => l_eam_wo_quality_rec
					, x_return_status    => l_return_status
					, x_mesg_token_tbl   => l_mesg_token_tbl
				 );

				 IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR THEN
					l_other_message := 'EAM_QA_CHECK_REQ';
					l_other_token_tbl(1).token_name  := 'OP_SEQ';
					l_other_token_tbl(1).token_value := l_eam_wo_quality_rec.operation_seq_number;
					RAISE EXC_SEV_QUIT_RECORD;
				 END IF;

		         END ;  -- End for begin K


		        END LOOP; -- FOR K

			BEGIN

				   IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion validating Quality Record Insert Row . . .'); END IF;
				   EAM_WO_QUA_UTILITY_PVT.insert_row
				   (
					   p_collection_id	=> colllection_id_temp
					 , p_eam_wo_quality_tbl  => p_eam_wo_quality_tbl
					 , x_eam_wo_quality_tbl  => l_eam_wo_quality_temp_tbl
					 , x_return_status       => l_return_status
					 , x_mesg_token_tbl      => l_mesg_token_tbl
				  );


				IF l_return_status  <> 'S' THEN
					x_return_status:=FND_API.G_RET_STS_ERROR;
					l_other_message := 'EAM_OP_QUAINSERT_CSEV_SKIP';
					l_other_token_tbl(1).token_name  := 'OP_SEQ';
					l_other_token_tbl(1).token_value := l_eam_wo_quality_rec.operation_seq_number;
					RAISE EXC_SEV_QUIT_RECORD;
				END IF;
			END ;
		END IF; -- END FOR Quality records > 0

		IF l_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
		   BEGIN

			IF l_asset_number IS NOT NULL THEN

				SELECT  cii.instance_number,cii.instance_id into l_asset_instance_number,
				  l_asset_instance_id
				  FROM  wip_discrete_jobs wdj,csi_item_instances cii
				 WHERE  wdj.wip_entity_id = l_eam_op_comp_rec.wip_entity_id
				   AND  wdj.maintenance_object_type = 3
				   AND  wdj.maintenance_object_id = cii.instance_id
				   AND  cii.serial_number = l_asset_number;
			END IF;



				IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion Checking quality mandatory plans remain . . .'); END IF;
				mandatory_qua_plan :=qa_web_txn_api.quality_mandatory_plans_remain(
					p_txn_number       => 33 ,
					p_organization_id  => l_org_id ,
					pk1                => l_asset_group_name ,    -- Asset Grp
					pk2                => l_asset_number  ,    -- Asset no
					pk3                => l_asset_activity  ,    -- Asset Act
					pk4                => l_wip_entity_name  ,    -- Work ordrr name
					pk5		   => l_eam_op_comp_rec.operation_seq_num ,
					pk6		   => l_asset_instance_number ,
					p_wip_entity_id    => l_wip_entity_id  ,     -- work order id
					p_collection_id    => l_eam_op_comp_rec.qa_collection_id
				 );

				IF mandatory_qua_plan = 'Y' THEN

					l_other_message := 'EAM_OPCMPL_MAND_PLAN';
					l_other_token_tbl(1).token_name  := 'OP_SEQ';
					l_other_token_tbl(1).token_value := l_eam_op_comp_rec.operation_seq_num;

					x_return_status := FND_API.G_RET_STS_ERROR;

					raise EXC_SEV_QUIT_RECORD;
				END IF;
		   END;
		END IF;

		IF p_eam_wo_quality_tbl.COUNT > 0 AND
			l_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  THEN

		    BEGIN
		    	   contextStr := '162='||l_asset_group_id||'@163='
			    ||l_asset_number||'@2147483550='||l_asset_instance_id||'@165='
			    ||l_wip_entity_id||'@199='||l_eam_op_comp_rec.operation_seq_num||'@164='||l_asset_activity_id;
		        IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion Calling qa_web_txn_api.post_background_results. . .'); END IF;
			qa_web_txn_api.post_background_results(
				p_txn_number         =>  33 ,
				p_org_id             => l_org_id  ,
				p_context_values     => contextStr ,
				p_collection_id      => l_eam_op_comp_rec.qa_collection_id
			);

		        EXCEPTION WHEN OTHERS THEN
			    l_token_tbl(1).token_name  := 'OP_SEQ';
			    l_token_tbl(1).token_value :=  l_eam_op_comp_rec.operation_seq_num;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;

			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_OP_CMPL_BACK_ERR'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );

			    x_return_status := FND_API.G_RET_STS_ERROR;

			   raise EXC_SEV_QUIT_RECORD;
		    END ;

			IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion Calling qa_results_pub.enable_and_fire_action . . .'); END IF;

			qa_result_grp.enable_and_fire_action(
			 p_api_version         => 1.0  ,
			 p_collection_id       => l_eam_op_comp_rec.qa_collection_id   ,
		         x_return_status       => l_return_status  ,
			 x_msg_count           => l_msg_count   ,
			 x_msg_data            => l_msg_data
		         );

			IF l_return_status <> 'S' THEN
			    l_token_tbl(1).token_name  := 'OP_SEQ';
			    l_token_tbl(1).token_value :=  l_eam_op_comp_rec.operation_seq_num;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;

			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_OP_QUALITY_COMMMIT'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );

			    x_return_status := FND_API.G_RET_STS_ERROR;

			   raise EXC_SEV_QUIT_RECORD;
			END IF;

		END IF;



		IF(l_workflow_enabled='Y' AND (l_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE)
		            AND (Wf_Event.TEST(l_op_completed_event)<>'NONE' )   ) THEN

			                                                            SELECT last_unit_completion_date
										    INTO l_op_sched_end_date
										    FROM WIP_OPERATIONS
										    WHERE wip_entity_id= l_eam_op_comp_rec.wip_entity_id
										    AND operation_seq_num = l_eam_op_comp_rec.operation_seq_num;

                                                                                    l_is_last_operation := 'N';
										    select DECODE(count(won.next_operation),0,'Y','N')
										    INTO l_is_last_operation
										    from wip_operation_networks won
										    where won.wip_entity_id =  l_eam_op_comp_rec.wip_entity_id and
										    won.prior_operation = l_eam_op_comp_rec.operation_seq_num;

										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Op Completed  event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR( l_eam_op_comp_rec.wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>l_wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(l_org_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ACTUAL_COMPLETION_DATE',
													    p_value => TO_CHAR(l_eam_op_comp_rec.actual_end_date),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'SCHEDULED_COMPLETION_DATE',
													    p_value => TO_CHAR(l_op_sched_end_date),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'IS_LAST_OPERATION',
													    p_value => l_is_last_operation,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(l_workflow_type),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);

										    Wf_Event.Raise(	p_event_name => l_op_completed_event,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Operation Completed Event','After raising event');

		END IF;   --end of check for raising op complete event


	EXCEPTION -- Exception handler for main Operation records

		    WHEN EXC_SEV_QUIT_RECORD THEN

		      l_out_eam_op_comp_tbl		:= l_eam_op_comp_tbl;

		      EAM_ERROR_MESSAGE_PVT.Log_Error
		      (
			      p_eam_op_comp_tbl			=>	l_eam_op_comp_tbl

			     , x_eam_wo_comp_rec		=>	l_out_eam_wo_comp_rec
			     , x_eam_wo_quality_tbl		=>	l_out_eam_wo_quality_tbl
			     , x_eam_meter_reading_tbl		=>	l_out_eam_meter_reading_tbl
			     , x_eam_counter_prop_tbl		=>      l_out_eam_counter_prop_tbl
			     , x_eam_wo_comp_rebuild_tbl	=>	l_out_eam_wo_comp_rebuild_tbl
			     , x_eam_wo_comp_mr_read_tbl	=>	l_out_eam_wo_comp_mr_read_tbl
			     , x_eam_op_comp_tbl		=>	l_out_eam_op_comp_tbl
			     , x_eam_request_tbl		=>	l_out_eam_request_tbl

			     , p_mesg_token_tbl			=>	l_mesg_token_tbl
			     , p_error_status			=>	FND_API.G_RET_STS_ERROR
			     , p_error_scope			=>	EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
			     , p_other_message			=>	l_other_message
			     , p_other_status			=>	EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
			     , p_other_token_tbl		=>	l_other_token_tbl

			     , p_error_level			=>	EAM_ERROR_MESSAGE_PVT.G_WO_COMP_LEVEL
		     );

			l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();

			 x_return_status		:=	FND_API.G_RET_STS_ERROR;
			 x_msg_count              	:=	l_msg_count;

		    RETURN;
	END ; -- End for op count > 0

	END LOOP;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PVT.COMP_UNCOMP_OPERATION : End==========================================================') ; END IF ;

END COMP_UNCOMP_OPERATION;













PROCEDURE SERVICE_WORKREQUEST_ASSO
	(
	  p_eam_request_tbl	    IN EAM_PROCESS_WO_PUB.eam_request_tbl_type
	, x_eam_request_tbl	    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_request_tbl_type
	, x_return_status           OUT NOCOPY VARCHAR2
	, x_msg_count               OUT NOCOPY NUMBER
	)
	IS
	l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_return_status         VARCHAR2(1) ;

	l_eam_request_tbl	EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_request_rec	EAM_PROCESS_WO_PUB.eam_request_rec_type;
	l_out_eam_request_rec	EAM_PROCESS_WO_PUB.eam_request_rec_type;

	l_org_id		NUMBER;
	l_wip_entity_id		NUMBER;
	l_valid_transaction     BOOLEAN := TRUE ;
	l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
	l_other_message         VARCHAR2(2000);
	l_token_tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;
	l_msg_count		NUMBER;
	L_OUT_EAM_REQUEST_TBL	EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_out_eam_wo_comp_rec		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_counter_prop_tbl	EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_wo_quality_tbl	EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;

	BEGIN

	IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request Service Request association procedure begin ');  END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_return_status	:= FND_API.G_RET_STS_SUCCESS;

	l_eam_request_tbl := p_eam_request_tbl;

	l_eam_request_rec := p_eam_request_tbl(p_eam_request_tbl.FIRST);

	l_org_id	:= l_eam_request_rec.organization_id;
	l_wip_entity_id := l_eam_request_rec.wip_entity_id;

	FOR i IN p_eam_request_tbl.FIRST..p_eam_request_tbl.LAST LOOP
	begin
		l_eam_request_rec := p_eam_request_tbl(i);

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request Service Request association: Transaction Type Validity . . . ');  END IF;

		VALIDATE_TRANSACTION_TYPE
		(   p_transaction_type  => l_eam_request_rec.transaction_type
		,   p_entity_name       => 'WORK_SERVICE_REQUEST'
		,   p_entity_id         => l_eam_request_rec.wip_entity_id
		,   x_valid_transaction => l_valid_transaction
		,   x_mesg_token_tbl    => l_Mesg_Token_Tbl
		);
		IF NOT l_valid_transaction
		THEN
		    x_eam_request_tbl(i).return_status	:= EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		    l_other_message := 'EAM_WR_INVALID_TXN_TYPE';
		    l_other_token_tbl(1).token_name  := 'REQUEST_ID';
		    l_other_token_tbl(1).token_value := l_eam_request_rec.request_id;
		    RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request Service Request association: : Check Required . . .'); END IF;

		EAM_REQUEST_VALIDATE_PVT.CHECK_REQUIRED
		(
		  p_eam_request_rec	=> l_eam_request_rec
		 , x_return_status	=> l_return_status
		 , x_mesg_token_tbl	=> l_Mesg_Token_Tbl
		 );

		  IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR THEN
		  			x_eam_request_tbl(i).return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
					l_other_message := 'EAM_WR_CHK_REQUIRED';
					l_other_token_tbl(1).token_name  := 'REQUEST_ID';
					l_other_token_tbl(1).token_value := l_eam_request_rec.request_id;
					RAISE EXC_SEV_QUIT_RECORD;
		  END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request Service Request association: : Attribute Defaulting . . .'); END IF;

		EAM_REQUEST_DEFAULT_PVT.Attribute_Defaulting
		(
			 p_eam_request_rec    => l_eam_request_rec ,
			 x_eam_request_rec    => l_out_eam_request_rec ,
			 x_return_status      => l_return_status
		);

		l_eam_request_rec := l_out_eam_request_rec;

		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR THEN
		  			x_eam_request_tbl(i).return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
					l_other_message := 'EAM_WR_ATTR_DEFAULT';
					l_other_token_tbl(1).token_name  := 'REQUEST_ID';
					l_other_token_tbl(1).token_value := l_eam_request_rec.request_id;
					RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request Service Request association: : Check Attributes . . .'); END IF;

		EAM_REQUEST_VALIDATE_PVT.CHECK_ATTRIBUTES
		(
			 p_eam_request_rec      => l_eam_request_rec
			 , x_return_status      => l_return_status
			 , x_mesg_token_tbl     => l_mesg_token_tbl
		);

		IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR THEN
		  			x_eam_request_tbl(i).return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
					l_other_message := 'EAM_WR_CHECK_ATTR';
					l_other_token_tbl(1).token_name  := 'REQUEST_ID';
					l_other_token_tbl(1).token_value := l_eam_request_rec.request_id;
					RAISE EXC_SEV_QUIT_RECORD;
		END IF;

		IF GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Request Service Request association: : Associating/Disassociating Work /Service Request. . .'); END IF;

			IF l_eam_request_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE THEN
				EAM_REQUEST_UTILITY_PVT.INSERT_ROW
				(  p_eam_request_rec   => l_eam_request_rec
				 , x_return_status     => l_return_status
				 , x_mesg_token_tbl    => l_mesg_token_tbl
				 );
			END IF;

			IF l_eam_request_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE THEN
				EAM_REQUEST_UTILITY_PVT.DELETE_ROW
				(  p_eam_request_rec   => l_eam_request_rec
				 , x_return_status     => l_return_status
				 , x_mesg_token_tbl    => l_mesg_token_tbl
				 );

			END IF;

			IF l_return_status = EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR THEN
		  			x_eam_request_tbl(i).return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
					l_other_message := 'EAM_WR_INSERT_REC';
					l_other_token_tbl(1).token_name  := 'REQUEST_ID';
					l_other_token_tbl(1).token_value := l_eam_request_rec.request_id;
					RAISE EXC_SEV_QUIT_RECORD;
			END IF;

			x_eam_request_tbl(i).return_status := FND_API.G_RET_STS_SUCCESS;
	END;
	END LOOP;

	EXCEPTION

		    WHEN EXC_SEV_QUIT_RECORD THEN

		      l_out_eam_request_tbl		:= l_eam_request_tbl;

		      EAM_ERROR_MESSAGE_PVT.Log_Error
		      (
			      p_eam_request_tbl			=>	l_eam_request_tbl

			     , x_eam_wo_comp_rec		=>	l_out_eam_wo_comp_rec
			     , x_eam_wo_quality_tbl		=>	l_out_eam_wo_quality_tbl
			     , x_eam_meter_reading_tbl		=>	l_out_eam_meter_reading_tbl
			     , x_eam_counter_prop_tbl		=>      l_out_eam_counter_prop_tbl
			     , x_eam_wo_comp_rebuild_tbl	=>	l_out_eam_wo_comp_rebuild_tbl
			     , x_eam_wo_comp_mr_read_tbl	=>	l_out_eam_wo_comp_mr_read_tbl
			     , x_eam_op_comp_tbl		=>	l_out_eam_op_comp_tbl
			     , x_eam_request_tbl		=>	l_out_eam_request_tbl

			     , p_mesg_token_tbl			=>	l_mesg_token_tbl
			     , p_error_status			=>	FND_API.G_RET_STS_ERROR
			     , p_error_scope			=>	EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
			     , p_other_message			=>	l_other_message
			     , p_other_status			=>	EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
			     , p_other_token_tbl		=>	l_other_token_tbl

			     , p_error_level			=>	EAM_ERROR_MESSAGE_PVT.G_WO_COMP_LEVEL
		     );

			l_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();
			x_return_status          	:=	EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
			x_msg_count              	:=	l_msg_count;

		    RETURN;

	END SERVICE_WORKREQUEST_ASSO;


END EAM_PROCESS_WO_PVT;

/
