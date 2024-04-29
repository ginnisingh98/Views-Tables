--------------------------------------------------------
--  DDL for Package Body EAM_WORKPERMIT_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKPERMIT_WORKFLOW_PVT" AS
/* $Header: EAMVWPWB.pls 120.0.12010000.3 2010/04/20 10:33:52 vboddapa noship $ */
/***************************************************************************
--
--  Copyright (c) 2009 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME: EAMVWPWB.pls
--
--  DESCRIPTION: Body of package EAM_WORKPERMIT_WORKFLOW_PVT
--
--  NOTES
--
--  HISTORY
--
--  18-FEB-2010   Madhuri Shah     Initial Creation
***************************************************************************/

/********************************************************************
* Procedure     : Launch_Workflow
* Purpose       : Function called from subscription .This will in turn launch the workflow
*********************************************************************/

function Launch_Workflow
                  ( p_subscription_guid in raw
                  , p_event in out NOCOPY wf_event_t
                  ) return varchar2 IS

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
BEGIN


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

END Launch_Workflow;



/********************************************************************
* Procedure     : Update_Status_Approved
* Purpose       : Procedure called from Work Permit Release Approval when the workflow is approved
*********************************************************************/
PROCEDURE Update_Status_Approved
                  ( itemtype  in varchar2
                    , itemkey   in varchar2
                    , actid     in number
                    , funcmode  in varchar2
                    , resultout out NOCOPY varchar2
                  )IS

                  l_permit_id number := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'PERMIT_ID');
                  l_permit_name varchar2(240):= wf_engine.GetItemAttrtext( itemtype => itemtype,
                      itemkey => itemkey, aname => 'PERMIT_NAME');
                  l_new_system_status number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'NEW_SYSTEM_STATUS');
                  l_new_permit_status  number :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'NEW_PERMIT_STATUS');
                  l_organization_id number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'ORGANIZATION_ID');

                  l_request_id            number;
                  l_err_msg               varchar2(2000);
                  l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                  l_status_error                 EXCEPTION;

                  l_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
		  l_old_work_permit_header_rec EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
                  lx_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
                  l_permit_wo_association_tbl EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type;

                  l_output_dir            VARCHAR2(512);
                  l_return_status      VARCHAR2(1);
                  l_msg_count          NUMBER;
BEGIN

-- This procedure will call work permit public API( procedure PROCESS_PERMIT ) for processing of the work permit record with the new status and the pending flag as 'N'
If (funcmode = 'RUN') then

  /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

   l_work_permit_header_rec.user_id :=  fnd_global.user_id;
   l_work_permit_header_rec.responsibility_id := fnd_global.resp_id;
   l_work_permit_header_rec.transaction_type :=   EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
   l_work_permit_header_rec.header_id  := l_permit_id;
   l_work_permit_header_rec.batch_id   := 1;
   l_work_permit_header_rec.permit_id := l_permit_id;
   l_work_permit_header_rec.organization_id := l_organization_id;
   l_work_permit_header_rec.status_type := l_new_system_status;
   l_work_permit_header_rec.user_defined_status_id    :=  l_new_permit_status;
   l_work_permit_header_rec.pending_flag    :=   'N';
   l_work_permit_header_rec.permit_id :=  l_permit_id;
   l_work_permit_header_rec.permit_name :=  l_permit_name;

-- To populate existing values
   EAM_PERMIT_VALIDATE_PVT.Check_Existence
        (  p_work_permit_header_rec   => l_work_permit_header_rec
           , x_work_permit_header_rec  => l_old_work_permit_header_rec
           , x_mesg_token_Tbl          => l_Mesg_Token_Tbl
           , x_return_Status           => l_return_status
        );

   l_work_permit_header_rec.description :=  l_old_work_permit_header_rec.description;
   l_work_permit_header_rec.valid_from :=  l_old_work_permit_header_rec.valid_from;
   l_work_permit_header_rec.valid_to :=  l_old_work_permit_header_rec.valid_to;
   l_work_permit_header_rec.approved_by := FND_GLOBAL.user_id;


      EAM_PROCESS_PERMIT_PVT.PROCESS_WORK_PERMIT(
           p_bo_identifier             => 'EAM'
         , p_api_version_number      	 => 1.0
         , p_init_msg_list           	 => TRUE
         , p_commit                  	 => 'N'
         , p_work_permit_header_rec  	 => l_work_permit_header_rec
         , p_permit_wo_association_tbl => l_permit_wo_association_tbl
         , x_work_permit_header_rec  	 => lx_work_permit_header_rec
         , x_return_status           	 => l_return_status
         , x_msg_count               	 => l_msg_count
         , p_debug                     => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir             	 => l_output_dir
         , p_debug_filename          	 => 'workflowpermitapproved.log'
         , p_debug_file_mode        	 => 'W'
     );

      if nvl(l_return_status, 'S') <> 'S' then
        l_return_status := FND_API.G_RET_STS_ERROR;
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
    wf_core.context('EAMWPREL','UPDATE_STATUS_APPROVED',
      itemtype, itemkey, actid, funcmode);
    raise;
END Update_Status_Approved;



/********************************************************************
* Procedure     : Update_Status_Rejected
* Purpose       : Procedure called from Work Permit Release Approval when the workflow is Rejected
*********************************************************************/
PROCEDURE Update_Status_Rejected
                      ( itemtype  in varchar2
                      ,	itemkey   in varchar2
                      , actid     in number
                      , funcmode  in varchar2
                      , resultout out NOCOPY varchar2
                      )IS

                  l_permit_id number := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'PERMIT_ID');
                  l_permit_name varchar2(240):= wf_engine.GetItemAttrtext( itemtype => itemtype,
                      itemkey => itemkey, aname => 'PERMIT_NAME');
                  l_new_system_status number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'NEW_SYSTEM_STATUS');
                  l_new_permit_status  number :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'NEW_PERMIT_STATUS');
                  l_organization_id number:= wf_engine.GetItemAttrNumber( itemtype => itemtype,
                      itemkey => itemkey, aname => 'ORGANIZATION_ID');

                  l_request_id            number;
                  l_err_msg               varchar2(2000);
                  l_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                  l_status_error                 EXCEPTION;

                  l_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
                  lx_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
                  l_permit_wo_association_tbl EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type;

                  l_output_dir            VARCHAR2(512);
                  l_return_status      VARCHAR2(1);
                  l_msg_count          NUMBER;

BEGIN

If (funcmode = 'RUN') then


     /* get output directory path from database */
      EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

      l_work_permit_header_rec.user_id :=  fnd_global.user_id;
      l_work_permit_header_rec.responsibility_id := fnd_global.resp_id;
      l_work_permit_header_rec.transaction_type :=   EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
      l_work_permit_header_rec.header_id  := l_permit_id;
      l_work_permit_header_rec.batch_id   := 1;
      l_work_permit_header_rec.permit_id := l_permit_id;
      l_work_permit_header_rec.organization_id := l_organization_id;
      l_work_permit_header_rec.status_type :=7;        --Cancelled
      l_work_permit_header_rec.user_defined_status_id    :=    99;        --Cancelled by Approver
      l_work_permit_header_rec.pending_flag    :=   'N';


         EAM_PROCESS_PERMIT_PVT.PROCESS_WORK_PERMIT(
           p_bo_identifier             => 'EAM'
         , p_api_version_number      	 => 1.0
         , p_init_msg_list           	 => TRUE
         , p_commit                  	 => 'N'
         , p_work_permit_header_rec  	 => l_work_permit_header_rec
         , p_permit_wo_association_tbl => l_permit_wo_association_tbl
         , x_work_permit_header_rec  	 => lx_work_permit_header_rec
         , x_return_status           	 => l_return_status
         , x_msg_count               	 => l_msg_count
         , p_debug                     => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir             	 => l_output_dir
         , p_debug_filename          	 => 'workflowpermitapproved.log'
         , p_debug_file_mode        	 => 'W'
     );

      if nvl(l_return_status, 'S') <> 'S' then
        l_return_status := FND_API.G_RET_STS_ERROR;
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
    wf_core.context('EAMWPREL','UPDATE_STATUS_REJECTED',
      itemtype, itemkey, actid, funcmode);
    raise;
END Update_Status_Rejected;




/********************************************************************
* Procedure     : Get_Next_Approver
* Purpose       : Procedure called from Work Permit Release Approval to
                  find the next approver
*********************************************************************/
procedure Get_Next_Approver
                        (  itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2
                        ) IS
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
   l_transaction_type := 'oracle.apps.eam.permit.release.approval';


    wf_engine.SetItemAttrText( itemtype =>  itemtype,
								     itemkey  => itemkey,
								     aname    => 'AME_TRANSACTION_TYPE',
								     avalue   =>     l_transaction_type);


    wf_engine.SetItemAttrText( itemtype =>  itemtype,
								     itemkey  => itemkey,
								     aname    => 'AME_TRANSACTION_ID',
								     avalue   =>    l_transaction_id );

   --flagApproversAsNotifiedIn is set to false, later we update 1st approver as notified

    ame_api2.getNextApprovers4(applicationIdIn=>426,
                            transactionTypeIn=>l_transaction_type,
                            transactionIdIn=>l_transaction_id,
                            flagApproversAsNotifiedIn => ame_util.booleanFalse,
                            approvalProcessCompleteYNOut => l_is_approval_complete,
                            nextApproversOut=>l_next_approvers);

  if (l_is_approval_complete = ame_util.booleanTrue) then
    resultout:='COMPLETE:'||'APPROVAL_COMPLETE';
    return;
   end if;
   l_next_approvers_count := l_next_approvers.count;
   if (l_next_approvers_count >= 1) then
     l_next_approver := l_next_approvers(1);
   else
     resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
     return;
   end if;
   IF l_next_approver.approval_status = ame_util.exceptionStatus THEN
     raise   E_FAILURE;
   END IF;
   IF ((l_next_approver.name is null) and
     (l_next_approver.display_name is null) and
     (l_next_approver.orig_system is null) and
     (l_next_approver.orig_system_id is null)) THEN
     resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
     return;
   ELSE
     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_next_approver.name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => l_next_approver.display_name);
     if (l_next_approvers_count = 1) then
       resultout:='COMPLETE:'||'VALID_APPROVER';
     else --multiple next approvers exist, they should be notified in parallel
       resultout:='COMPLETE:'||'VALID_PARALLEL_APPROVER';
     end if;

       --Set first approver as notified, workflow handles one at a time
     ame_api2.updateApprovalStatus2(applicationIdIn=>426,
          transactionTypeIn=>'oracle.apps.eam.permit.release.approval',
          transactionIdIn=>l_transaction_id,
          approvalStatusIn => ame_util.notifiedStatus,
          approverNameIn => l_next_approver.name);
   --  return;
   END IF; -- approver is not null
 --END IF; -- run

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



/********************************************************************
* Procedure     : Update_AME_With_Response
* Purpose       : Procedure called from Permit Release Approval when an approver
                  responds to a notification
*********************************************************************/
procedure Update_AME_With_Response
                          ( itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2
                          ) IS
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
					transactionTypeIn=>'oracle.apps.eam.permit.release.approval',
					transactionIdIn=>l_transaction_id,
					approvalStatusIn => l_ame_status,
					approverNameIn => l_approver_name);

 ELSIF  ( funcmode = 'TRANSFER' ) THEN

        l_transaction_id :=  itemkey;
        l_forwardeeIn.name :=WF_ENGINE.context_new_role;
        l_original_approver_name:= WF_ENGINE.context_original_recipient;


          ame_api2.updateApprovalStatus2(applicationIdIn=>426,
					transactionTypeIn=>'oracle.apps.eam.permit.release.approval',
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



/********************************************************************
* Procedure     : Is_Approval_Required_Released
* Purpose       : This procedure will check if the approval is required for
                  the work permit release
*********************************************************************/

PROCEDURE Is_Approval_Required_Released
                        (  p_old_wp_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                          , p_new_wp_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                          , x_approval_required    OUT NOCOPY   BOOLEAN
                          , x_workflow_name        OUT NOCOPY    VARCHAR2
                          , x_workflow_process    OUT NOCOPY    VARCHAR2
                        )IS
BEGIN

IF(p_new_wp_rec.status_type =3 AND						--status is released
             ((p_new_wp_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_CREATE) OR
	        ((p_new_wp_rec.transaction_type=EAM_PROCESS_WO_PUB.G_OPR_UPDATE) AND
	         ((p_old_wp_rec.status_type IN (1,17,7) )   OR (p_old_wp_rec.status_type=6) ) ) )
	   )THEN
			     x_approval_required := TRUE;
			     x_workflow_name  := 'EAMWPREL';
			     x_workflow_process := 'EAM_WP_RELEASE_APPROVAL';
       END IF;

END Is_Approval_Required_Released;

END EAM_WORKPERMIT_WORKFLOW_PVT;



/
