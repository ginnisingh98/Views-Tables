--------------------------------------------------------
--  DDL for Package Body GMD_SS_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_APPROVAL_WF_PKG" AS
/* $Header: GMDQMSAB.pls 120.3.12000000.3 2007/02/07 12:09:49 rlnagara ship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  APPLICATION_ERROR EXCEPTION;
  -- Following function accepts FND userId and returns
  -- User name
  FUNCTION GET_FND_USER_NAME( userId Integer) RETURN VARCHAR2 IS
    CURSOR GET_USER_NAME IS
      SELECT USER_NAME
      FROM FND_USER
      WHERE USER_ID = userId;
    l_userName FND_USER.USER_NAME%TYPE;
  BEGIN
    OPEN GET_USER_NAME;
    FETCH GET_USER_NAME INTO l_userName;
    CLOSE GET_USER_NAME;
    RETURN l_userName;
  END GET_FND_USER_NAME;

  /********************************************************************************
   ***   This procedure is associated with GMDQMSAP_ISAPROVAL_REQUIRED workflow. **
   ***   This code will execute when Stability Status Business Event is raised.  **
   ***   This verifies whether approval required for this transaction or not     **
   ***   If approval is required then udated spec status to pending as defined   **
   ***   GMD_QC_STATUS_NEXT and populates workflow attributes                    **
   ********************************************************************************/

  PROCEDURE IS_APPROVAL_REQ  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS


    applicationId number :=552;
    transactionType varchar2(50) := 'GMDQM_STABILITY_CSTS';
    nextApprover ame_util.approverRecord;

    l_userID integer;
    l_userName    FND_USER.USER_NAME%TYPE;
    l_Requester   FND_USER.USER_NAME%TYPE;
    l_Owner       FND_USER.USER_NAME%TYPE;
    l_storage_name varchar2(200);

    lSSId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SS_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));
    l_notify_time_unit varchar2(100);
    l_grace_time_unit varchar2(100);

    lStartStatus_DESC VARCHAR2(240);
    lTargetStatus_DESC VARCHAR2(240);
    api_ret_status VARCHAR2(1);
    api_se_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
    l_message VARCHAR2(500);
    l_owner_name varchar2(100);

   cursor get_storage_name (storage_id_in number) is
        select storage_plan_name
        from gmd_storage_plans_b
        where storage_plan_id = storage_id_in;

    --this cursor definition changed as part of convergence
    cursor get_disp_Attr IS
        select a.ss_id, a.ss_no, b.meaning, a.description, c.concatenated_segments item_no, c.description item_desc1, a.revision,
         e.organization_code ORGANIZATION_CODE, a.owner, a.NOTIFICATION_LEAD_TIME , a.NOTIFICATION_LEAD_TIME_UNIT,
         a.TESTING_GRACE_PERIOD , a.TESTING_GRACE_PERIOD_UNIT , a.MATERIAL_SOURCES_CNT,
         a.STORAGE_CONDITIONS_CNT , a.PACKAGES_CNT , a.BASE_SPEC_ID , d.SPEC_NAME, d.SPEC_VERS,
         f.organization_code LAB_ORGANIZATION_CODE , a.storage_plan_id ,
         a.SCHEDULED_START_DATE , a.SCHEDULED_END_DATE , a.REVISED_START_DATE ,
         a.REVISED_END_DATE ,  a.ACTUAL_START_DATE ,  a.ACTUAL_END_DATE ,
         a.RECOMMENDED_SHELF_LIFE , a.RECOMMENDED_SHELF_LIFE_UNIT , a.DELETE_MARK , a.LAST_UPDATED_BY
        from gmd_stability_studies a,
                gmd_Qc_status b,
                mtl_system_items_kfv c,
                gmd_specifications d,
                mtl_parameters e,
                mtl_parameters f
        where a.inventory_item_id = c.inventory_item_id
          and a.organization_id = c.organization_id
          and b.entity_type = 'STABILITY'
          and b.status_code = a.status
          and a.BASE_SPEC_ID = d.spec_id
          and a.ss_id = lSSId
      and a.organization_id = e.organization_id
      and a.lab_organization_id = f.organization_id;


     disp_attr_rec  get_disp_Attr%ROWTYPE;

  cursor get_owner_name (owner_id_in number) is
        select user_name from fnd_user
        where user_id = owner_id_in ;


  CURSOR get_ss_time_unit (p_time varchar2) IS
      SELECT meaning
      FROM gem_lookups
      WHERE lookup_type = 'GMD_QC_FREQUENCY_PERIOD'
      and   lookup_code = p_time ;

  cursor get_from_role is
     select nvl( text, '')
        from wf_Resources where name = 'WF_ADMIN_ROLE'
        and language = userenv('LANG')   ;

  l_from_role varchar2(2000);


  begin


    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('StabStudyStatus');
       gmd_debug.put_line('SS ID ' ||  lSSId );
    END IF;

        open get_from_role ;
        fetch get_from_role into l_from_role ;
        close get_from_role ;


    IF p_funcmode = 'RUN' THEN
      --
      -- clear All Approvals from AME
      -- following API removes previous instance of approval group from AME tables
      --

      IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Getting approvers ');
      END IF;


      ame_api.clearAllApprovals(applicationIdIn   => applicationId,
                              transactionIdIn   =>  lSSId ,
                              transactionTypeIn => transactionType);

      --
      -- Get the next approver who need to approve the trasaction
      --
      ame_api.getNextApprover(applicationIdIn   => applicationId,
                            transactionIdIn   => lSSId,
                            transactionTypeIn => transactionType,
                            nextApproverOut   => nextApprover);


          -- Get attributes Required for display
          open get_disp_Attr;
          FETCH get_disp_Attr INTO disp_attr_rec;
          IF get_disp_Attr%NOTFOUND THEN
            WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,'NO VLAID SS ROW');
            raise APPLICATION_ERROR;
          END IF;
          close get_disp_Attr;


      IF nextApprover.user_id  IS NULL and nextApprover.person_id IS NULL
      THEN
           --
           -- Means either no AME rule is matching for this transaction ID or Approver list is empty.
           --
          l_userID :=  disp_attr_rec.owner;


        elsif  nextApprover.person_id  IS NOT NULL THEN
           --
           -- if we got HR Person then we have to find corresponding FND USER
           -- assumption here is all HR user configured in AME will have
           -- corresponding  FND USER
           --
           l_userID := ame_util.personIdToUserId(nextApprover.person_id);
        ELSE
          l_userID :=  nextApprover.user_id;
        END IF;

      IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Approver ID ' || l_userID);
      END IF;


        wf_engine.setitemattrtext(p_itemtype, p_itemkey,'USER_ID',l_userID);
        l_userName := GET_FND_USER_NAME(l_userId);

        --
        -- Update status to pending
        --

        GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_STABILITY_STUDIES_B'
                                , p_id            => lSSId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'P'
                                , p_entity_type   => 'STABILITY'       --RLNAGARA B5727585
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );


       IF api_ret_status = 'S' THEN

          -- Get attributes Required for display
          open get_disp_Attr;
          FETCH get_disp_Attr INTO disp_attr_rec;
          IF get_disp_Attr%NOTFOUND THEN
            WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,'NO VLAID SS ROW');
            raise APPLICATION_ERROR;
          END IF;

          open get_storage_name(disp_attr_rec.storage_plan_id);
                fetch get_storage_name into l_storage_name;
          close get_storage_name ;

          open get_ss_time_unit (disp_attr_rec.NOTIFICATION_LEAD_TIME_UNIT);
                fetch get_ss_time_unit into l_notify_time_unit;
          close get_ss_time_unit ;

          open get_ss_time_unit (disp_attr_rec.TESTING_GRACE_PERIOD_UNIT);
                fetch get_ss_time_unit into l_grace_time_unit;
          close get_ss_time_unit ;

          IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Setting workflow attributes');
          END IF;

          l_requester := GET_FND_USER_NAME(disp_attr_rec.LAST_UPDATED_BY);
          l_owner     := GET_FND_USER_NAME(disp_attr_rec.OWNER);
          lStartStatus_DESC := GMD_SS_APPROVAL_WF_PKG.GET_STATUS_MEANING(lStartStatus,'STABILITY');
          lTargetStatus_DESC:= GMD_SS_APPROVAL_WF_PKG.GET_STATUS_MEANING(lTargetStatus,'STABILITY');

          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',disp_attr_rec.ORGANIZATION_CODE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_NAME',disp_attr_rec.SPEC_NAME);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'BASE_SPEC',disp_attr_rec.SPEC_NAME);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_VERS',disp_attr_rec.SPEC_VERS);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'LAB_ORGN',disp_attr_rec.LAB_ORGANIZATION_CODE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REQUESTER',l_requester);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_NO',disp_attr_rec.ITEM_NO);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_DESC',disp_attr_rec.ITEM_DESC1);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REVISION',disp_attr_rec.REVISION);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'START_STATUS_DESC',lStartStatus_DESC);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS_DESC',lTargetStatus_DESC);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'APPROVER',l_userName);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'STORAGE_PLAN',l_storage_name);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SS_NAME',disp_attr_rec.SS_NO);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SS_DESC',disp_attr_rec.description);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'NOTIFY_TIME',
                disp_attr_rec.NOTIFICATION_LEAD_TIME || ' ' || l_notify_time_unit);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'GRACE_TIME',
                disp_attr_rec.TESTING_GRACE_PERIOD || ' ' || l_grace_time_unit);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SCHED_START_DATE',disp_attr_rec.SCHEDULED_START_DATE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SCHED_END_DATE',disp_attr_rec.SCHEDULED_END_DATE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REVISED_START_DATE',disp_attr_rec.REVISED_START_DATE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REVISED_END_DATE',disp_attr_rec.REVISED_END_DATE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ACTUAL_START_DATE',disp_attr_rec.ACTUAL_START_DATE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ACTUAL_END_DATE',disp_attr_rec.ACTUAL_END_DATE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER',l_owner);


          l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => '#FROM_ROLE',
                                                  avalue => l_userName );

        WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                                         aname => 'GMDQMSAP_TIMEOUT',
                                               avalue => l_wf_timeout);
        WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                                         aname => 'GMDQMSAP_MESG_CNT',
                                               avalue => 1);


          p_resultout := 'COMPLETE:Y';
        ELSE
          WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;

    END IF;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,'Invalid SS ID');
    raise;
  END IS_APPROVAL_REQ;

/**************************************************************************************
 *** This procedure is associated with GMDQSMAP_APP_COMMENT activity of the workflow **
 *** When user enters comments in response to a notification this procedure appends  **
 *** comments to internal variable so that full history can be shown in notification **
 *** body.                                                                           **
 **************************************************************************************/


  PROCEDURE APPEND_COMMENTS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS

      l_comment       VARCHAR2(4000):= wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQMSAP_COMMENT');
      l_mesg_comment  VARCHAR2(4000):= wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQMSAP_DISP_COMMENT');
      l_performer     VARCHAR2(80)  := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQMSAP_CURR_PERFORMER');
  BEGIN
     IF (p_funcmode = 'RUN' AND l_comment IS NOT NULL) THEN
         BEGIN
           l_mesg_comment := l_mesg_comment||wf_core.newline||l_performer||' : '||FND_DATE.DATE_TO_CHARDT(SYSDATE)||
                             wf_core.newline||l_comment;
           l_comment := null;
         EXCEPTION WHEN OTHERS THEN
           NULL;
         END;

           WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQMSAP_DISP_COMMENT',
                                   avalue => l_mesg_comment);
           WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQMSAP_COMMENT',
                                   avalue => l_comment);
       END IF;
  END APPEND_COMMENTS;

/***************************************************************************************
 *** This procedure is associated with VERIFY_ANY_MORE_APPR activity of the workflow  **
 *** once current approver approves status change request this procedure call AME API **
 *** to verify any more approvers need to approve this request. if it needs some more **
 *** approvals then it sets approver info to workflow attrbute. now workflow moves to **
 *** next approval processing. this will continue either all approves approves the    **
 *** request or any one of the rejects. if all approvals are complete then it sets    **
 ***  status to target status                                                         **
 ***************************************************************************************/


  PROCEDURE ANY_MORE_APPROVERS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := 'GMDQM_STABILITY_CSTS';
    nextApprover ame_util.approverRecord;
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    lSSId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SS_ID');
    l_userID integer;
    l_userName    FND_USER.USER_NAME%TYPE;
    api_ret_status VARCHAR2(1);
    api_se_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);

  BEGIN

    IF p_funcmode = 'RUN' THEN

      --
      -- Get the next approver who need to approve the trasaction
      --
      ame_api.getNextApprover(applicationIdIn   => applicationId,
                            transactionIdIn   => lSSId,
                            transactionTypeIn => transactionType,
                            nextApproverOut   => nextApprover);

      IF nextApprover.user_id  IS NULL and nextApprover.person_id IS NULL
      THEN
           --
           -- All Approvers are approved.
           -- change status of the object to target status
           --

          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_STABILITY_STUDIES_B'
                                , p_id            => lSSId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'A'
                                , p_entity_type   => 'STABILITY'        --RLNAGARA B5727585
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );


        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;

          IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Target Status ' || lTargetStatus);
          END IF;

        if (lTargetStatus = 400) then
                -- We got approved, so kick off API to create sampling events
                 GMD_SS_WFLOW_GRP.events_for_status_change(lSSId , api_se_ret_status) ;
        elsif (lTargetStatus = 700) then
                -- We need to launch; Enable the Mother workflow for testing
                gmd_api_pub.raise ('oracle.apps.gmd.qm.ss.test',
                                        lSSId);
        end if;

          IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Called needed APIs');
          END IF;

        p_resultout := 'COMPLETE:N';
      ELSE
        IF nextApprover.person_id  IS NOT NULL THEN
           --
           -- if we got HR Person then we have to find corresponding FND USER
           -- assumption here is all HR user configured in AME will have
           -- corresponding  FND USER
           --
           l_userID := ame_util.personIdToUserId(nextApprover.person_id);
        ELSE
          l_userID :=  nextApprover.user_id;
        END IF;
        l_userName := GET_FND_USER_NAME(l_userId);
        wf_engine.setitemattrtext(p_itemtype, p_itemkey,'USER_ID',l_userID);
        wf_engine.setitemattrtext(p_itemtype, p_itemkey,'APPROVER',l_userName);
        p_resultout := 'COMPLETE:Y';
      END IF;
    END IF;


  END ANY_MORE_APPROVERS;

 /*************************************************************************************
  *** Following procedure is to verify any reminder is required when workflow timeout**
  *** occurs                                                                         **
  *************************************************************************************/

PROCEDURE REMINDAR_CHECK (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDQMSAP_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                 aname => 'GMDQMSAP_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQMSAP_CURR_PERFORMER',
                                   avalue => l_approver);
       END IF;
END;


/****************************************************************************************
 *** This procedure is associated with GMDQMSAP_NOTI_NOT_RESP activity of the workflow **
 *** When approver fails to respond to notification defined in GMD: Workflow timeout   **
 *** profile this procedure sets spec status to start status and ends the workflow     **
 *** approval process.                                                                 **
 ****************************************************************************************/

  PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SS_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
  BEGIN
     IF p_funcmode = 'RUN' THEN


          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_STABILITY_STUDIES_B'
                                , p_id            => lSpecId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'S'
                                , p_entity_type   => 'STABILITY'        --RLNAGARA B5727585
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );

        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;
     END IF;
  END NO_RESPONSE;

/****************************************************************************************
 *** This procedure is associated with GMDQSPAP_NOTI_REWORK activity of the workflow   **
 *** When approver rejects status change request procedure sets spec status to         **
 *** rework status and ends the workflow approval process.                             **
 ****************************************************************************************/


  PROCEDURE REQ_REJECTED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := 'GMDQM_STABILITY_CSTS';
    nextApprover ame_util.approverRecord;
    lSSId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SS_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    l_userID       VARCHAR2(100) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'USER_ID');
    new_user_id VARCHAR2(100);
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
  BEGIN
     IF p_funcmode = 'RUN' THEN

      --
      -- Update Approver action
      --
          ame_api.getNextApprover(applicationIdIn   => applicationId,
                                  transactionIdIn   => lSSId,
                                  transactionTypeIn => transactionType,
                                  nextApproverOut   => nextApprover);
          IF nextApprover.person_id  IS NOT NULL THEN
             --
             -- if we got HR Person then we have to find corresponding FND USER
             -- assumption here is all HR user configured in AME will have
             -- corresponding  FND USER
             --
            new_user_id := ame_util.personIdToUserId(nextApprover.person_id);
          ELSE
            new_user_id :=  nextApprover.user_id;
          END IF;
          IF new_user_id = l_userID THEN
            nextApprover.approval_status := ame_util.rejectStatus;
            ame_api.updateApprovalStatus(applicationIdIn   => applicationId,
                                         transactionIdIn   => lSSId,
                                         transactionTypeIn => transactionType,
                                         ApproverIn   => nextApprover);
          END IF;


          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_STABILITY_STUDIES_B'
                                , p_id            => lSSId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'R'
                                , p_entity_type   => 'STABILITY'        --RLNAGARA B5727585
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );

        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMD_SS_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;
     END IF;

  END REQ_REJECTED;

/****************************************************************************************
 *** This procedure is associated with GMDQSPAP_NOTI_APPROVED activity of the workflow **
 *** When approver approves status change request procedure sets AME Approver status   **
 *** to approved status and continues with approval process to verify any more         **
 *** approvals required                                                                **
 ****************************************************************************************/


  PROCEDURE REQ_APPROVED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := 'GMDQM_STABILITY_CSTS';
    nextApprover ame_util.approverRecord;
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SS_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    l_userID       VARCHAR2(100) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'USER_ID');
    new_user_id VARCHAR2(100);
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
  BEGIN
     IF p_funcmode = 'RUN' THEN
      --
      --
      -- Update Approver action
      --
          ame_api.getNextApprover(applicationIdIn   => applicationId,
                                  transactionIdIn   => lSpecId,
                                  transactionTypeIn => transactionType,
                                  nextApproverOut   => nextApprover);
          IF nextApprover.person_id  IS NOT NULL THEN
             --
             -- if we got HR Person then we have to find corresponding FND USER
             -- assumption here is all HR user configured in AME will have
             -- corresponding  FND USER
             --
            new_user_id := ame_util.personIdToUserId(nextApprover.person_id);
          ELSE
            new_user_id :=  nextApprover.user_id;
          END IF;
          IF new_user_id = l_userID THEN
            nextApprover.approval_status := ame_util.approvedStatus;
            ame_api.updateApprovalStatus(applicationIdIn   => applicationId,
                                         transactionIdIn   => lSpecId,
                                         transactionTypeIn => transactionType,
                                         ApproverIn        => nextApprover);
          END IF;

     END IF;

  END REQ_APPROVED;

 /**************************************************************************************
  *** Following procedure accepts Status Code and entity type and resolves to Meaning **
  **************************************************************************************/

  FUNCTION GET_STATUS_MEANING(P_STATUS_CODE NUMBER,
                              P_ENTITY_TYPE VARCHAR2) RETURN VARCHAR2 IS
    CURSOR GET_STAT_MEANING IS
      SELECT MEANING
      FROM GMD_QC_STATUS
      WHERE STATUS_CODE = P_STATUS_CODE
        AND ENTITY_TYPE = P_ENTITY_TYPE;
    l_status_meaning GMD_QC_STATUS.MEANING%TYPE;
  BEGIN
    OPEN GET_STAT_MEANING;
    FETCH GET_STAT_MEANING INTO l_status_meaning;
    CLOSE GET_STAT_MEANING;
    RETURN l_status_meaning;
  END;

  FUNCTION GET_STATUS_NEXT_MEANING(P_STATUS_CODE NUMBER,
                              P_ENTITY_TYPE VARCHAR2) RETURN VARCHAR2 IS

    target_status number;

    CURSOR GET_STAT_MEANING IS
      SELECT MEANING
      FROM GMD_QC_STATUS
      WHERE STATUS_CODE = target_status
        AND ENTITY_TYPE = P_ENTITY_TYPE;
    l_status_meaning GMD_QC_STATUS.MEANING%TYPE;

  BEGIN

    if (p_status_code = 200) then
        /* requesting Approval */
        target_status := 400;
   elsif (p_status_code = 500) then
        /* requesting Launch */
        target_status := 700;
   elsif (p_status_code = 900) then
        /* requesting Cancel */
        target_status := 1000;
   end if;

    OPEN GET_STAT_MEANING;
    FETCH GET_STAT_MEANING INTO l_status_meaning;
    CLOSE GET_STAT_MEANING;
    RETURN l_status_meaning;
  END;


 /**************************************************************************************
  *** Following procedure is to raise Status Change approval business event           **
  **************************************************************************************/

  PROCEDURE RAISE_SS_APPR_EVENT(p_SS_ID           NUMBER,
                                  p_START_STATUS      NUMBER,
                                  p_TARGET_STATUS     NUMBER) IS
    l_parameter_list wf_parameter_list_t :=wf_parameter_list_t( );
    l_event_name VARCHAR2(80) := 'oracle.apps.gmd.qm.ss.csts';

  BEGIN
    wf_log_pkg.wf_debug_flag:=TRUE;
    wf_event.AddParameterToList('SS_ID', p_SS_ID,l_parameter_list);
    wf_event.AddParameterToList('START_STATUS',p_START_STATUS ,l_parameter_list);
    wf_event.AddParameterToList('TARGET_STATUS',p_TARGET_STATUS ,l_parameter_list);
    wf_event.raise(p_event_name => L_event_name,
                   p_event_key  => p_SS_ID,
                   p_parameters => l_parameter_list);
    l_parameter_list.DELETE;
  END;

END GMD_SS_APPROVAL_WF_PKG;

/
