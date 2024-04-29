--------------------------------------------------------
--  DDL for Package Body GMDQSPEC_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDQSPEC_APPROVAL_WF_PKG" AS
/* $Header: GMDQSAPB.pls 120.5 2006/04/24 05:00:58 rlnagara noship $ */


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
   ***   This procedure is associated with GMDQSPAP_ISAPROVAL_REQUIRED workflow. **
   ***   This code will execute when Spec Approval Business Event is raised.     **
   ***   This verfifies whether approval required for this transaction or not    **
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
    transactionType varchar2(50) := 'oracle.apps.gmd.qm.spec.sts';
    nextApprover ame_util.approverRecord;
    l_userID integer;
    l_userName    FND_USER.USER_NAME%TYPE;
    l_Requester   FND_USER.USER_NAME%TYPE;
    l_Owner       FND_USER.USER_NAME%TYPE;
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));
    lStartStatus_DESC VARCHAR2(240);
    lTargetStatus_DESC VARCHAR2(240);
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
    l_message VARCHAR2(500);

   /* cursor get_disp_Attr IS
      SELECT SPEC.SPEC_NAME
            ,SPEC.SPEC_VERS
            ,SPEC.SPEC_DESC
            ,SPEC.GRADE
            ,SPEC.SPEC_STATUS
            ,SPEC.OWNER_ORGN_CODE
            ,SPEC.OWNER_ID
            ,SPEC.LAST_UPDATED_BY
            ,ITEM.ITEM_NO
            ,ITEM.ITEM_DESC1
            ,ORGN.ORGN_NAME
            ,QCSTAT.MEANING
            ,SPEC.SPEC_TYPE
            ,SPEC.OVERLAY_IND
            ,SPEC.BASE_SPEC_ID
      FROM GMD_SPECIFICATIONS SPEC
          ,IC_ITEM_MST ITEM
          ,SY_ORGN_MST ORGN
          ,GMD_QC_STATUS QCSTAT
      WHERE SPEC.ITEM_ID     = ITEM.ITEM_ID (+)
        AND ORGN.ORGN_CODE   = SPEC.OWNER_ORGN_CODE
        AND SPEC.SPEC_STATUS = QCSTAT.STATUS_CODE
        AND SPEC.SPEC_ID     = lSpecId;*/

    -- INVCONV, NSRIVAST
    -- Chagned the table names and attributes
    cursor get_disp_Attr IS

    -- bug 4924550  sql id 14690143  start
/*      SELECT SPEC.SPEC_NAME
              ,SPEC.SPEC_VERS
              ,SPEC.SPEC_DESC
              ,SPEC.GRADE_CODE
              ,SPEC.SPEC_STATUS
              ,SPEC.OWNER_ORGANIZATION_ID
              ,SPEC.OWNER_ID
              ,SPEC.LAST_UPDATED_BY
              ,ITEM.CONCATENATED_SEGMENTS
              ,SPEC.REVISION
              ,ITEM.DESCRIPTION
              --,HAOU.NAME
	      ,MO.ORGANIZATION_NAME
	      ,MO.ORGANIZATION_CODE
              ,QCSTAT.MEANING
              ,SPEC.SPEC_TYPE
              ,SPEC.OVERLAY_IND
              ,SPEC.BASE_SPEC_ID
        FROM GMD_SPECIFICATIONS SPEC
            ,mtl_system_items_kfv ITEM
            ,mtl_parameters ORGN
            ,GMD_QC_STATUS QCSTAT
	    ,MTL_ORGANIZATIONS MO
        WHERE SPEC.INVENTORY_ITEM_ID     = ITEM.INVENTORY_ITEM_ID (+)
          AND ORGN.ORGANIZATION_ID       = SPEC.OWNER_ORGANIZATION_ID
           AND SPEC.OWNER_ORGANIZATION_ID = nvl(ITEM.ORGANIZATION_ID ,SPEC.OWNER_ORGANIZATION_ID)
          AND SPEC.SPEC_STATUS           = QCSTAT.STATUS_CODE
          AND SPEC.SPEC_ID               = lSpecId
	  AND ORGN.ORGANIZATION_ID       = MO.ORGANIZATION_ID; */
    -- INVCONV, NSRIVAST

    SELECT SPEC.SPEC_NAME
              ,SPEC.SPEC_VERS
              ,SPEC.SPEC_DESC
              ,SPEC.GRADE_CODE
              ,SPEC.SPEC_STATUS
              ,SPEC.OWNER_ORGANIZATION_ID
              ,SPEC.OWNER_ID
              ,SPEC.LAST_UPDATED_BY
              ,ITEM.CONCATENATED_SEGMENTS
              ,SPEC.REVISION
              ,ITEM.DESCRIPTION
              --,HAOU.NAME
	      			,HR.NAME ORGANIZATION_NAME -- sql id
	      			,ORGN.ORGANIZATION_CODE   -- sql id
              ,QCSTAT.MEANING
              ,SPEC.SPEC_TYPE
              ,SPEC.OVERLAY_IND
              ,SPEC.BASE_SPEC_ID
        FROM
            GMD_SPECIFICATIONS SPEC
            ,mtl_system_items_kfv ITEM
            ,mtl_parameters ORGN
            ,GMD_QC_STATUS QCSTAT
	    --,MTL_ORGANIZATIONS MO
	    		  ,HR_ALL_ORGANIZATION_UNITS_TL HR -- sql id
        WHERE SPEC.INVENTORY_ITEM_ID     = ITEM.INVENTORY_ITEM_ID (+)
          AND ORGN.ORGANIZATION_ID       = SPEC.OWNER_ORGANIZATION_ID
          and ORGN.ORGANIZATION_ID = HR.ORGANIZATION_ID -- sql id
          and hr.language = userenv('LANG') -- sql id
           AND SPEC.OWNER_ORGANIZATION_ID = nvl(ITEM.ORGANIZATION_ID ,SPEC.OWNER_ORGANIZATION_ID)
          AND SPEC.SPEC_STATUS           = QCSTAT.STATUS_CODE
          AND SPEC.SPEC_ID               = lSpecId ;
	 -- AND ORGN.ORGANIZATION_ID       = MO.ORGANIZATION_ID; -- sql id
-- bug 4924550  sql id 14690143  end

     disp_attr_rec  get_disp_Attr%ROWTYPE;

  cursor get_from_role is
     select nvl( text, '')
        from wf_Resources where name = 'WF_ADMIN_ROLE'
        and language = userenv('LANG')   ;

  l_from_role varchar2(2000);
  l_spectype_Desc VARCHAR2(50) := NULL;

--RLNAGARA Bug 4706861 Rework
  CURSOR get_spec_det(p_spec_id NUMBER) IS
   SELECT SPEC_NAME,SPEC_VERS
   FROM GMD_SPECIFICATIONS_B
   WHERE SPEC_ID = p_spec_id;

  l_base_spec_name VARCHAR2(80);
  l_base_spec_vers NUMBER;


  begin


    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Specapproval');
       gmd_debug.put_line('Spec ID ' || lSpecId);
       gmd_debug.put_line('Start ' || lStartStatus);
       gmd_debug.put_line('End ' || lTargetStatus);
    END IF;

        open get_from_role ;
        fetch get_from_role into l_from_role ;
        close get_from_role ;


    IF p_funcmode = 'RUN' THEN
      --
      -- clear All Approvals from AME
      -- following API removes previous instance of approval group from AME tables
      --
      ame_api.clearAllApprovals(applicationIdIn   => applicationId,
                              transactionIdIn   => lSpecId,
                              transactionTypeIn => transactionType);
      --
      -- Get the next approver who need to approve the trasaction
      --
      ame_api.getNextApprover(applicationIdIn   => applicationId,
                            transactionIdIn   => lSpecId,
                            transactionTypeIn => transactionType,
                            nextApproverOut   => nextApprover);

      IF nextApprover.user_id  IS NULL and nextApprover.person_id IS NULL
      THEN
           --
           -- Means either no AME rule is matching for this transaction ID or Approver list is empty.
           -- change status of the object to target status
           --
          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_SPECIFICATIONS_B'
                                , p_id            => lSpecId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'A'
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );

        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;

        IF (l_debug = 'Y') THEN
               gmd_debug.put_line('No approvers ');
        END IF;

        p_resultout := 'COMPLETE:N';

      ELSE
          --
          --  We got the first approver from AME
          --
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
        wf_engine.setitemattrtext(p_itemtype, p_itemkey,'USER_ID',l_userID);
        l_userName := GET_FND_USER_NAME(l_userId);
        --
        -- Update status to pending
        --

          IF (l_debug = 'Y') THEN
               gmd_debug.put_line('Requesting approvers');
               gmd_debug.put_line('Final Status ' || lTargetStatus);
          END IF;

        GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_SPECIFICATIONS_B'
                                , p_id            => lSpecId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'P'
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );

       IF api_ret_status = 'S' THEN
          -- Get attributes Required for display
          open get_disp_Attr;
          FETCH get_disp_Attr INTO disp_attr_rec;
          IF get_disp_Attr%NOTFOUND THEN
            WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,FND_MESSAGE.GET_STRING('GMD','GMD_QC_INVALID_SPEC_ID'));
            raise APPLICATION_ERROR;
          END IF;

          IF (l_debug = 'Y') THEN
               gmd_debug.put_line('Setting up workflow attributes');
          END IF;

          l_requester := GET_FND_USER_NAME(disp_attr_rec.LAST_UPDATED_BY);
          l_owner     := GET_FND_USER_NAME(disp_attr_rec.OWNER_ID);
          lStartStatus_DESC := GMDQSPEC_APPROVAL_WF_PKG.GET_STATUS_MEANING(lStartStatus,'S');
          lTargetStatus_DESC:= GMDQSPEC_APPROVAL_WF_PKG.GET_STATUS_MEANING(lTargetStatus,'S');

          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_NAME',disp_attr_rec.SPEC_NAME);
          wf_engine.setitemattrnumber(p_itemtype, p_itemkey,'SPEC_VERS',disp_attr_rec.SPEC_VERS);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_DESC',disp_attr_rec.SPEC_DESC);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_STATUS',disp_attr_rec.MEANING);
--        wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',disp_attr_rec.OWNER_ORGN_CODE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',disp_attr_rec.ORGANIZATION_CODE);  -- INVCONV, NSRIVAST
--          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_NAME',disp_attr_rec.ORGN_NAME);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_NAME',disp_attr_rec.ORGANIZATION_NAME);  -- INVCONV, NSRIVAST
--          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'GRADE',disp_attr_rec.GRADE);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'GRADE',disp_attr_rec.GRADE_CODE);  -- INVCONV, NSRIVAST
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_NAME',l_owner);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REQUESTER',l_requester);
--          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_NO',disp_attr_rec.ITEM_NO);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_NO',disp_attr_rec.CONCATENATED_SEGMENTS); -- INVCONV, NSRIVAST
--          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_DESC',disp_attr_rec.ITEM_DESC1);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_DESC',disp_attr_rec.DESCRIPTION); -- INVCONV, NSRIVAST
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'START_STATUS_DESC',lStartStatus_DESC);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS_DESC',lTargetStatus_DESC);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'APPROVER',l_userName);

--RLNAGARA Bug # 4706861

         IF disp_attr_rec.SPEC_TYPE IS NOT NULL THEN
            SELECT DESCRIPTION INTO l_spectype_desc
            FROM GEM_LOOKUPS
            WHERE LOOKUP_TYPE = 'GMD_QC_SPEC_TYPE'
            AND LOOKUP_CODE = disp_attr_rec.SPEC_TYPE ;
            wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_TYPE', l_spectype_desc);
         END IF;

--            wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_TYPE',disp_attr_rec.SPEC_TYPE);

--RLNAGARA Bug # 4706861


	  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OVERLAY', disp_attr_rec.OVERLAY_IND);

--RLNAGARA Bug 4706861 Rework
          IF disp_attr_rec.BASE_SPEC_ID IS NOT NULL THEN
	    OPEN get_spec_det(disp_attr_rec.BASE_SPEC_ID);
	    FETCH get_spec_det INTO l_base_spec_name, l_base_spec_vers;
	    CLOSE get_spec_det;
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'BASE_SPEC', l_base_spec_name);
          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'BASE_SPEC_VERS', l_base_spec_vers);
	  END IF;
--          wf_engine.setitemattrtext(p_itemtype, p_itemkey,'BASE_SPEC', disp_attr_rec.BASE_SPEC_ID);



          wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'ITEM_REVISION', disp_attr_rec.REVISION);  -- INVCONV, NSRIVAST

          /* Depending on whether the Spec is for an item or monitor, fill out the
                tokenized message and set it in the workflow */
          if (disp_attr_rec.SPEC_TYPE = 'M') THEN
                /* This is a monitoring Spec */
                  FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_APPROVAL_MON');
                  --FND_MESSAGE.SET_TOKEN('SPEC_TYPE', disp_attr_rec.SPEC_TYPE);
		  FND_MESSAGE.SET_TOKEN('SPEC_TYPE', 'Monitoring');
                  FND_MESSAGE.SET_TOKEN('OVERLAY', disp_attr_rec.OVERLAY_IND);
                  FND_MESSAGE.SET_TOKEN('BASE_SPEC', disp_attr_rec.BASE_SPEC_ID);
          ELSE
                /* This is an Item Spec */
                  FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_APPROVAL_ITEM');
                  --FND_MESSAGE.SET_TOKEN('ITEM_NO', disp_attr_rec.ITEM_NO);
                  --FND_MESSAGE.SET_TOKEN('ITEM_DESC', disp_attr_rec.ITEM_DESC1);
                  --FND_MESSAGE.SET_TOKEN('GRADE', disp_attr_rec.GRADE);
                  FND_MESSAGE.SET_TOKEN('ITEM_NO', disp_attr_rec.CONCATENATED_SEGMENTS);
                  FND_MESSAGE.SET_TOKEN('ITEM_DESC', disp_attr_rec.DESCRIPTION);
                  FND_MESSAGE.SET_TOKEN('GRADE', disp_attr_rec.GRADE_CODE);
                  --FND_MESSAGE.SET_TOKEN('SPEC_TYPE', disp_attr_rec.SPEC_TYPE);
		  FND_MESSAGE.SET_TOKEN('SPEC_TYPE', 'Item');
          END IF;

                 /* These are the common attributes in both messages */
                  FND_MESSAGE.SET_TOKEN('SPEC_NAME', disp_attr_rec.SPEC_NAME);
                  FND_MESSAGE.SET_TOKEN('SPEC_VERS', disp_attr_rec.SPEC_VERS);
                  FND_MESSAGE.SET_TOKEN('SPEC_DESC', disp_attr_rec.SPEC_DESC);
                  FND_MESSAGE.SET_TOKEN('SPEC_STATUS', disp_attr_rec.MEANING);
                  --FND_MESSAGE.SET_TOKEN('OWNER_ORGN_CODE', disp_attr_rec.OWNER_ORGN_CODE);
                  --FND_MESSAGE.SET_TOKEN('OWNER_ORGN_NAME', disp_attr_rec.ORGN_NAME);
                  FND_MESSAGE.SET_TOKEN('OWNER_ORGN_CODE', disp_attr_rec.ORGANIZATION_CODE); --INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('OWNER_ORGN_NAME', disp_attr_rec.ORGANIZATION_NAME); --INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('OWNER_NAME', l_owner);
                  FND_MESSAGE.SET_TOKEN('REQUESTER', l_requester);
                  FND_MESSAGE.SET_TOKEN('START_STATUS_DESC', lStartStatus_DESC);
                  FND_MESSAGE.SET_TOKEN('TARGET_STATUS_DESC', lTargetStatus_DESC);
                  FND_MESSAGE.SET_TOKEN('APPROVER', l_userName);


          /* Set the message attribute, MSG, in the workflow */
--                FND_MESSAGE.SET_TOKEN('GMDQSPAP_MSG', FND_MESSAGE.GET() );


          wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'GMDQSPAP_MSG', FND_MESSAGE.GET());

          l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

            WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => '#FROM_ROLE',
                                                  avalue => l_userName );
        WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                                       aname => 'GMDQSPAP_TIMEOUT',
                                               avalue => l_wf_timeout);
        WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                                       aname => 'GMDQSPAP_MESG_CNT',
                                               avalue => 1);
          p_resultout := 'COMPLETE:Y';
        ELSE
          WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',
                                        p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;
      END IF;
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,'Invalid Spec ID');
    raise;
  END IS_APPROVAL_REQ;

/**************************************************************************************
 *** This procedure is associated with GMDQSPAP_APP_COMMENT activity of the workflow **
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

      l_comment       VARCHAR2(4000):= wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQSPAP_COMMENT');
      l_mesg_comment  VARCHAR2(4000):= wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQSPAP_DISP_COMMENT');
      l_performer     VARCHAR2(80)  := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQSPAP_CURR_PERFORMER');
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
                                           aname => 'GMDQSPAP_DISP_COMMENT',
                                   avalue => l_mesg_comment);
           WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQSPAP_COMMENT',
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
 *** spec status to target status                                                     **
 ***************************************************************************************/


  PROCEDURE ANY_MORE_APPROVERS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := 'oracle.apps.gmd.qm.spec.sts';
    nextApprover ame_util.approverRecord;
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_ID');
    l_userID integer;
    l_userName    FND_USER.USER_NAME%TYPE;
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
  BEGIN
    IF p_funcmode = 'RUN' THEN
      --
      -- Get the next approver who need to approve the trasaction
      --
      ame_api.getNextApprover(applicationIdIn   => applicationId,
                            transactionIdIn   => lSpecId,
                            transactionTypeIn => transactionType,
                            nextApproverOut   => nextApprover);

      IF nextApprover.user_id  IS NULL and nextApprover.person_id IS NULL
      THEN
           --
           -- All Approvers are approved.
           -- change status of the object to target status
           --

          IF (l_debug = 'Y') THEN
               gmd_debug.put_line('Finished approvers; changing status');
               gmd_debug.put_line('Final Status ' || lTargetStatus);
          END IF;

          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_SPECIFICATIONS_B'
                                , p_id            => lSpecId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'A'
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );
        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
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
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDQSPAP_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                               aname => 'GMDQSPAP_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQSPAP_CURR_PERFORMER',
                                   avalue => l_approver);
       END IF;
END;


/****************************************************************************************
 *** This procedure is associated with GMDQSPAP_NOTI_NOT_RESP activity of the workflow **
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
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
  BEGIN
     IF p_funcmode = 'RUN' THEN
          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_SPECIFICATIONS_B'
                                , p_id            => lSpecId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'S'
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );
        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
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
    transactionType varchar2(50) := 'oracle.apps.gmd.qm.spec.sts';
    nextApprover ame_util.approverRecord;
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_ID');
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
            nextApprover.approval_status := ame_util.rejectStatus;
            ame_api.updateApprovalStatus(applicationIdIn   => applicationId,
                                         transactionIdIn   => lSpecId,
                                         transactionTypeIn => transactionType,
                                         ApproverIn   => nextApprover);
          END IF;
          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_SPECIFICATIONS_B'
                                , p_id            => lSpecId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'R'
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );
        IF api_ret_status <> 'S' THEN
          WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
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
    transactionType varchar2(50) := 'oracle.apps.gmd.qm.spec.sts';
    nextApprover ame_util.approverRecord;
    lSpecId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_ID');
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

 /**************************************************************************************
  *** Following procedure is to raise Spec approval business event                    **
  **************************************************************************************/

  PROCEDURE RAISE_SPEC_APPR_EVENT(p_SPEC_ID           NUMBER,
                                  p_START_STATUS      NUMBER,
                                  p_TARGET_STATUS     NUMBER) IS
    l_parameter_list wf_parameter_list_t :=wf_parameter_list_t( );
    l_event_name VARCHAR2(80) := 'oracle.apps.gmd.qm.spec.sts';
  BEGIN
    wf_log_pkg.wf_debug_flag:=TRUE;
    wf_event.AddParameterToList('SPEC_ID', p_SPEC_ID,l_parameter_list);
    wf_event.AddParameterToList('START_STATUS',p_START_STATUS ,l_parameter_list);
    wf_event.AddParameterToList('TARGET_STATUS',p_TARGET_STATUS ,l_parameter_list);
    wf_event.raise(p_event_name => L_event_name,
                   p_event_key  => p_SPEC_ID,
                   p_parameters => l_parameter_list);
    l_parameter_list.DELETE;
  END;
END GMDQSPEC_APPROVAL_WF_PKG;

/
