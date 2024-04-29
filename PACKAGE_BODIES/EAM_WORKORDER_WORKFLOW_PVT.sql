--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDER_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDER_WORKFLOW_PVT" AS
/* $Header: EAMVWWFB.pls 120.0.12010000.5 2011/07/11 11:51:44 vboddapa ship $*/

g_pkg_name    CONSTANT VARCHAR2(50):= 'EAM_WORKORDER_WORKFLOW_PVT';
g_module_name CONSTANT VARCHAR2(60):= 'eam.plsql.' || g_pkg_name;

/*  Function called from subscription .This will in turn laucnh the workflow
*/
function Launch_Workflow
(p_subscription_guid in raw,
p_event in out NOCOPY wf_event_t)
return varchar2
is
Debug_File      UTL_FILE.FILE_TYPE;
x_return_status VARCHAR2(50);
l_param_list wf_parameter_list_t;
l_param wf_parameter_t;
l_param_idx NUMBER;
l_name VARCHAR2(200);
l_value VARCHAR2(200);
l_item_type VARCHAR2(200);
l_item_key VARCHAR2(200);
l_wf_process      VARCHAR2(200);

begin

l_param_list:=p_event.getParameterList;

l_param_idx := l_param_list.FIRST;
		 while ( l_param_idx is not null) loop

							l_param := l_param_list(l_param_idx);

							IF(l_param.name = 'WORKFLOW_NAME')   THEN
								l_item_type := l_param.value;
							END IF;

							IF(l_param.name = 'WORKFLOW_PROCESS') THEN
							      l_wf_process :=   l_param.value;
							END IF;

							l_param_idx := l_param_list.NEXT(l_param_idx);
		end loop;

IF(l_item_type IS NULL OR l_wf_process IS NULL) THEN
    RETURN 'ERROR';
END IF;

l_item_key := p_event.getEventKey;

wf_engine.CreateProcess( itemtype =>l_item_type,
                           itemkey  => l_item_key,
                           process  => l_wf_process );


l_param_idx := l_param_list.FIRST;
		while ( l_param_idx is not null) loop

					l_param := l_param_list(l_param_idx);

					BEGIN

					 wf_engine.SetItemAttrText( itemtype => l_item_type,
								     itemkey  => l_item_key,
								     aname    => l_param.name,
								     avalue   => l_param.value);

					EXCEPTION
					    WHEN OTHERS THEN    --if attribute in event is not present in workflow...an exception will be thrown.
					           NULL;
					 END;

					l_param_idx := l_param_list.NEXT(l_param_idx);
		end loop;

 wf_engine.StartProcess( itemtype => l_item_type,
                          itemkey  => l_item_key);


x_return_status := 'SUCCESS';
return x_return_status;

exception
   when others then
    return 'ERROR';
end Launch_Workflow;

/*Procedure called from Work Order Release Approval when the workflow is approved*/
PROCEDURE Update_Status_Approved( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is
   l_wip_entity_id number := wf_engine.GetItemAttrNumber( itemtype => itemtype,
			 itemkey => itemkey, aname => 'WIP_ENTITY_ID');
  l_wip_entity_name varchar2(240):= wf_engine.GetItemAttrtext( itemtype => itemtype,
		    itemkey => itemkey, aname => 'WIP_ENTITY_NAME');
  l_new_system_status number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
		 itemkey => itemkey, aname => 'NEW_SYSTEM_STATUS');
  l_new_wo_status  number :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
		  itemkey => itemkey, aname => 'NEW_WO_STATUS');
  l_organization_id number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
    itemkey => itemkey, aname => 'ORGANIZATION_ID');
  l_request_id            number;
  l_err_msg               varchar2(2000);
  l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_status_error                 EXCEPTION;

      l_workorder_rec                                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl                                          EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl                  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl                                 EAM_PROCESS_WO_PUB.eam_res_tbl_type;
       l_eam_res_usage_tbl                         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl                            EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl                             EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl                             EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl                       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;


      l_eam_wo_rec_out                                  EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl_out                                          EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl_out                  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl_out                                 EAM_PROCESS_WO_PUB.eam_res_tbl_type;
       l_eam_res_usage_tbl_out                         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl_out                            EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl_out                             EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl_out                             EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl_out                        EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

     l_output_dir            VARCHAR2(512);
     l_return_status      VARCHAR2(1);
     l_msg_count          NUMBER;
     l_msg_data        VARCHAR2(2000);

BEGIN


  If (funcmode = 'RUN') then

  /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

   --commenting for bug 10149577
   --l_workorder_rec.user_id :=  fnd_global.user_id;
   --l_workorder_rec.responsibility_id := fnd_global.resp_id;
   l_workorder_rec.transaction_type :=   EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
   l_workorder_rec.header_id  := l_wip_entity_Id;
   l_workorder_rec.batch_id   := 1;
   l_workorder_rec.wip_entity_id := l_wip_entity_Id;
   l_workorder_rec.organization_id := l_organization_id;
  l_workorder_rec.status_type := l_new_system_status;
  l_workorder_rec.user_defined_status_id    :=    l_new_wo_status;
  l_workorder_rec.pending_flag    :=   'N';


    EAM_PROCESS_WO_PUB.PROCESS_WO
        (  p_init_msg_list					=>TRUE
         , p_commit						=> 'N'
         , p_eam_wo_rec					=>     l_workorder_rec
         , p_eam_op_tbl                                 =>       l_eam_op_tbl
         , p_eam_op_network_tbl		      =>        l_eam_op_network_tbl
         , p_eam_res_tbl				      =>         l_eam_res_tbl
         , p_eam_res_inst_tbl		      =>         l_eam_res_inst_tbl
         , p_eam_sub_res_tbl		      =>         l_eam_sub_res_tbl
         , p_eam_res_usage_tbl		     =>           l_eam_res_usage_tbl
         , p_eam_mat_req_tbl		     =>          l_eam_mat_req_tbl
         , p_eam_direct_items_tbl		      =>         l_eam_direct_items_tbl
         , x_eam_wo_rec              			=>     l_eam_wo_rec_out
         , x_eam_op_tbl                                   =>       l_eam_op_tbl_out
         , x_eam_op_network_tbl                  =>        l_eam_op_network_tbl_out
         , x_eam_res_tbl					=>     l_eam_res_tbl_out
         , x_eam_res_inst_tbl				=>     l_eam_res_inst_tbl_out
         , x_eam_sub_res_tbl			        =>      l_eam_sub_res_tbl_out
         , x_eam_res_usage_tbl		       =>       l_eam_res_usage_tbl_out
         , x_eam_mat_req_tbl				=>     l_eam_mat_req_tbl_out
         , x_eam_direct_items_tbl			=>      l_eam_direct_items_tbl_out
         , x_return_status                                =>           l_return_status
         , x_msg_count                                   =>          l_msg_count
         , p_debug                                           =>         NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir                                     =>      l_output_dir
         , p_debug_filename                         =>      'workflowapproved.log'
         , p_debug_file_mode                      =>   'W'
         );


      if nvl(l_return_status, 'S') <> 'S' then
        l_return_status := FND_API.G_RET_STS_ERROR;
				--        if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
				--          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
				--            'Error while releasing using EAM_WO_CHANGE_STATUS_PVT.Change_Status');
        		--        end if;
        RAISE l_status_error;
      ELSE
             COMMIT;
      end if;

    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('EAMWOREL','UPDATE_STATUS_APPROVED',
      itemtype, itemkey, actid, funcmode);
    raise;
END Update_Status_Approved;


/*  Procedure called from Work Order Release Approval when the workflow is Rejected
*/
PROCEDURE Update_Status_Rejected( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is
l_wip_entity_id number := wf_engine.GetItemAttrNumber( itemtype => itemtype,
		   itemkey => itemkey, aname => 'WIP_ENTITY_ID');
  l_wip_entity_name varchar2(240):= wf_engine.GetItemAttrtext( itemtype => itemtype,
		    itemkey => itemkey, aname => 'WIP_ENTITY_NAME');
  l_organization_id number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
		    itemkey => itemkey, aname => 'ORGANIZATION_ID');
  l_request_id            number;
  l_err_msg               varchar2(2000);
  l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_status_error              EXCEPTION;

      l_workorder_rec                                EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl                                          EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl                  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl                                 EAM_PROCESS_WO_PUB.eam_res_tbl_type;
       l_eam_res_usage_tbl                         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl                            EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl                             EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl                             EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl                       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;


      l_eam_wo_rec_out                                  EAM_PROCESS_WO_PUB.eam_wo_rec_type;
      l_eam_op_tbl_out                                          EAM_PROCESS_WO_PUB.eam_op_tbl_type;
      l_eam_op_network_tbl_out                  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
      l_eam_res_tbl_out                                 EAM_PROCESS_WO_PUB.eam_res_tbl_type;
       l_eam_res_usage_tbl_out                         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
      l_eam_res_inst_tbl_out                            EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
      l_eam_sub_res_tbl_out                             EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
      l_eam_mat_req_tbl_out                             EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
      l_eam_direct_items_tbl_out                        EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

     l_output_dir            VARCHAR2(512);
     l_return_status      VARCHAR2(1);
     l_msg_count          NUMBER;

BEGIN


If (funcmode = 'RUN') then


  /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

   --commenting for bug 10149577
   --l_workorder_rec.user_id :=  fnd_global.user_id;
   --l_workorder_rec.responsibility_id := fnd_global.resp_id;
   l_workorder_rec.transaction_type :=   EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
   l_workorder_rec.header_id  := l_wip_entity_Id;
   l_workorder_rec.batch_id   := 1;
   l_workorder_rec.wip_entity_id := l_wip_entity_Id;
   l_workorder_rec.organization_id := l_organization_id;
  l_workorder_rec.status_type :=7;        --Cancelled
  l_workorder_rec.user_defined_status_id    :=    99;        --Cancelled by Approver
  l_workorder_rec.pending_flag    :=   'N';

    EAM_PROCESS_WO_PUB.PROCESS_WO
        (  p_init_msg_list					=>TRUE
         , p_commit						=> 'N'
         , p_eam_wo_rec					=>     l_workorder_rec
         , p_eam_op_tbl                                 =>       l_eam_op_tbl
         , p_eam_op_network_tbl		      =>        l_eam_op_network_tbl
         , p_eam_res_tbl				      =>         l_eam_res_tbl
         , p_eam_res_inst_tbl		      =>         l_eam_res_inst_tbl
         , p_eam_sub_res_tbl		      =>         l_eam_sub_res_tbl
         , p_eam_res_usage_tbl		     =>           l_eam_res_usage_tbl
         , p_eam_mat_req_tbl		     =>          l_eam_mat_req_tbl
         , p_eam_direct_items_tbl		      =>         l_eam_direct_items_tbl
         , x_eam_wo_rec              			=>     l_eam_wo_rec_out
         , x_eam_op_tbl                                   =>       l_eam_op_tbl_out
         , x_eam_op_network_tbl                  =>        l_eam_op_network_tbl_out
         , x_eam_res_tbl					=>     l_eam_res_tbl_out
         , x_eam_res_inst_tbl				=>     l_eam_res_inst_tbl_out
         , x_eam_sub_res_tbl			        =>      l_eam_sub_res_tbl_out
         , x_eam_res_usage_tbl		       =>       l_eam_res_usage_tbl_out
         , x_eam_mat_req_tbl				=>     l_eam_mat_req_tbl_out
         , x_eam_direct_items_tbl			=>      l_eam_direct_items_tbl_out
         , x_return_status                                =>           l_return_status
         , x_msg_count                                   =>          l_msg_count
         , p_debug                                           =>         NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir                                     =>      l_output_dir
         , p_debug_filename                         =>      'workflowapproved.log'
         , p_debug_file_mode                      =>   'W'
         );

      if nvl(l_return_status, 'S') <> 'S' then
        l_return_status := FND_API.G_RET_STS_ERROR;
				--        if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
				--          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
				--            'Error while releasing using EAM_WO_CHANGE_STATUS_PVT.Change_Status');
				--        end if;
        RAISE l_status_error;
      ELSE
             COMMIT;
      end if;

    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;


EXCEPTION
  when others then
    wf_core.context('EAMWOREL','UPDATE_STATUS_REJECTED',
      itemtype, itemkey, actid, funcmode);
    raise;
END Update_Status_Rejected;

/*  Procedure called from Work Order Release Approval to find the next approver
*/
procedure Get_Next_Approver(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  E_FAILURE                   EXCEPTION;
  l_transaction_id            number;
  l_next_approver             ame_util.approverRecord2;
  l_next_approvers            ame_util.approversTable2;
  l_next_approvers_count      number;
  l_approver_index            number;
  l_is_approval_complete      VARCHAR2(1);
  l_transaction_type      VARCHAR2(200);
  l_role_users  WF_DIRECTORY.UserTable;
  l_role_name                            VARCHAR2(320) ;
  l_role_display_name                    VARCHAR2(360)  ;

BEGIN

IF (funcmode = 'RUN') THEN

   l_transaction_id :=  TO_NUMBER(itemkey);
   l_transaction_type := 'oracle.apps.eam.workorder.release.approval';

    wf_engine.SetItemAttrText( itemtype =>  itemtype,
								     itemkey  => itemkey,
								     aname    => 'AME_TRANSACTION_TYPE',
								     avalue   =>     l_transaction_type);

    wf_engine.SetItemAttrText( itemtype =>  itemtype,
								     itemkey  => itemkey,
								     aname    => 'AME_TRANSACTION_ID',
								     avalue   =>    l_transaction_id );

    ame_api2.getNextApprovers4(applicationIdIn=>426,
                            transactionTypeIn=>l_transaction_type,
                            transactionIdIn=>l_transaction_id,
                            flagApproversAsNotifiedIn => ame_util.booleanTrue,
                            approvalProcessCompleteYNOut => l_is_approval_complete,
                            nextApproversOut=>l_next_approvers);

  if (l_is_approval_complete = ame_util.booleanTrue) then
    resultout:='COMPLETE:'||'APPROVAL_COMPLETE';
    return;

    --  Incase of consensus voting method, next approver count might be zero but there will be pending approvers
  elsif (l_next_approvers.Count = 0) then

    ame_api2.getPendingApprovers(applicationIdIn=>426,
                                transactionTypeIn=>l_transaction_type,
                                transactionIdIn=>l_transaction_id,
                                approvalProcessCompleteYNOut => l_is_approval_complete,
                                approversOut =>l_next_approvers);
  end if;

  l_next_approvers_count := l_next_approvers.Count;


  if (l_next_approvers_count = 0)  then
     resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
     return;
  end if;

  if (l_next_approvers_count > 0)  then
     resultout:='COMPLETE:'||'VALID_APPROVER';
     --return;
  end if;

  if (l_next_approvers_count = 1)  then
      l_next_approver:=l_next_approvers(l_next_approvers.first());
      wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_next_approver.name);

       wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => l_next_approver.display_name);
       resultout:='COMPLETE:'||'VALID_APPROVER';
     --return;
  end if;

    l_approver_index := l_next_approvers.first();

      while ( l_approver_index is not null ) loop
          l_role_users(l_approver_index):= l_next_approvers(l_approver_index).name ;

       l_approver_index := l_next_approvers.next(l_approver_index);


      end loop;

	  wf_directory.CreateAdHocRole2( role_name => l_role_name
                                  ,role_display_name => l_role_display_name
                                  ,language => NULL
                                  ,territory => NULL
                                  ,role_description => 'EAM ROLE DESC'
                                  ,notification_preference => null
                                  ,role_users => l_role_users
                                  ,email_address => null
                                  ,fax => null
                                  ,status => 'ACTIVE'
                                  ,expiration_date => null
                                  ,parent_orig_system => null
                                  ,parent_orig_system_id => null
                                  ,owner_tag => null
                                  );


	  wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'RECIPIENT_ROLE',
                                avalue => l_role_name
                                );
     return;

 END IF; -- run

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Get_Next_Approver;

 /*  Procedure called from Work Order Release Approval when an approver responds to a notification
*/
procedure Update_AME_With_Response(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  E_FAILURE                   EXCEPTION;
  l_transaction_id            number;
  l_nid                       number;
  l_gid                       number;
  l_approver_name             varchar2(240);
  l_result                    varchar2(100);
  l_ame_status                varchar2(20);
  l_original_approver_name         varchar2(240);
  l_forwardeeIn  ame_util.approverRecord2;


BEGIN
 IF (funcmode = 'RUN') THEN

				   l_transaction_id :=  itemkey;
				   l_gid := WF_ENGINE.context_nid;

                   SELECT responder,notification_id
                   into  l_approver_name,l_nid
                   FROM wf_notifications
                   WHERE group_id=l_gid
                   AND status = 'CLOSED';

			   l_result := Wf_Notification.GetAttrText(l_nid, 'RESULT');



				    if (l_result = 'APPROVED') then -- this may vary based on lookup type used for approval

				     l_ame_status := ame_util.approvedStatus;
				   elsif (l_result = 'REJECTED') then
				     l_ame_status := ame_util.rejectStatus;
				   else -- reject for lack of information, conservative approach
				     l_ame_status := ame_util.rejectStatus;
				   end if;
				   --Set approver as approved or rejected based on approver response
				   ame_api2.updateApprovalStatus2(applicationIdIn=>426,
					transactionTypeIn=>'oracle.apps.eam.workorder.release.approval',
					transactionIdIn=>l_transaction_id,
					approvalStatusIn => l_ame_status,
					approverNameIn => l_approver_name);


 ELSIF  ( funcmode = 'TRANSFER' ) THEN


        l_transaction_id :=  itemkey;
        l_forwardeeIn.name :=WF_ENGINE.context_new_role;
        l_original_approver_name:= WF_ENGINE.context_original_recipient;


          ame_api2.updateApprovalStatus2(applicationIdIn=>426,
					transactionTypeIn=>'oracle.apps.eam.workorder.release.approval',
					transactionIdIn=>l_transaction_id,
					approvalStatusIn => 'FORWARD',
					approverNameIn => l_original_approver_name,
          forwardeeIn => l_forwardeeIn );



 END IF; -- run

 resultout:= wf_engine.eng_completed || ':' || l_result;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Update_AME_With_Response;


/*  Procedure called from the public package 'EAM_WORKFLOW_DETAILS_PUB'
    This procedure will launch the seeded workflow when status is changed to Released
*/
PROCEDURE Is_Approval_Required_Released
(
p_old_wo_rec IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
p_new_wo_rec IN EAM_PROCESS_WO_PUB.eam_wo_rec_type,
   x_approval_required    OUT NOCOPY   BOOLEAN,
   x_workflow_name        OUT NOCOPY    VARCHAR2,
   x_workflow_process    OUT NOCOPY    VARCHAR2
)
IS
BEGIN

      IF(p_new_wo_rec.status_type =3 AND						--status is released
             ((p_new_wo_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_CREATE) OR
	        ((p_new_wo_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_UPDATE) AND
	         ((p_old_wo_rec.status_type IN (1,17,7) )   OR (p_old_wo_rec.status_type=6 AND p_old_wo_rec.date_released IS NULL) ) ) )
	   )THEN
			     x_approval_required := TRUE;
			     x_workflow_name  := 'EAMWOREL';
			     x_workflow_process := 'EAM_WO_RELEASE_APPROVAL';
       END IF;

END Is_Approval_Required_Released;

END EAM_WORKORDER_WORKFLOW_PVT;

/
