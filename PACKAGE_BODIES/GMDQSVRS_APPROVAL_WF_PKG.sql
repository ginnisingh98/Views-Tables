--------------------------------------------------------
--  DDL for Package Body GMDQSVRS_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDQSVRS_APPROVAL_WF_PKG" AS
/* $Header: GMDQSVRB.pls 120.3 2006/05/15 04:50:03 rkrishan noship $ */


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
   ***   This procedure is associated with GMDQSVRS_ISAPROVAL_REQUIRED workflow. **
   ***   This code will execute when Spec Validity Rule Approval Business Event  **
   ***   is raised. This verfifies whether approval required for this transaction**
   ***   or not. If approval is required then udated spec status to pending as   **
   ***   defined GMD_QC_STATUS_NEXT and populates workflow attributes            **
   ********************************************************************************/

  PROCEDURE IS_APPROVAL_REQ  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'EVENT_NAME');
    l_TABLE_NAME    varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TABLE_NAME');
    nextApprover ame_util.approverRecord;
    l_userID integer;
    l_userName    FND_USER.USER_NAME%TYPE;
    l_Requester   FND_USER.USER_NAME%TYPE;
    l_Owner       FND_USER.USER_NAME%TYPE;
    lSpecVRId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));
    lStartStatus_DESC VARCHAR2(240);
    lTargetStatus_DESC VARCHAR2(240);
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
    l_spec_type varchar2(10);

    /*====================================================
       BUG#491207 Replaced call to gmd_all_spec_vrs view
       with the following cursor.
      ====================================================*/

    cursor get_spec_type is
     SELECT 'I' spec_type
     FROM GMD_INVENTORY_SPEC_VRS v
     WHERE v.spec_vr_id = lSpecVRId
     UNION
     SELECT 'W' spec_type
     FROM GMD_WIP_SPEC_VRS V
     WHERE v.spec_vr_id = lSpecVRId
     UNION
     SELECT 'C' spec_type
     FROM GMD_CUSTOMER_SPEC_VRS V
     WHERE v.spec_vr_id = lSpecVRId
     UNION
     SELECT 'S' spec_type
     FROM GMD_SUPPLIER_SPEC_VRS V
     WHERE v.spec_vr_id = lSpecVRId
     UNION
     SELECT v.rule_type spec_type
     FROM GMD_MONITORING_SPEC_VRS V
     WHERE v.spec_vr_id = lSpecVRId
     UNION
     SELECT 'T' spec_type
     FROM GMD_STABILITY_SPEC_VRS V
     WHERE v.spec_vr_id = lSpecVRId;


/*=======================================
   BUG#4912074 - Replaced get_disp_Attr
   for performance and added subsequent
   queried to get additional data.
  ======================================*/

cursor get_disp_Attr IS
SELECT v.spec_vr_id, s.spec_name , s.spec_vers, 'I' spec_type,
    v.organization_id,
    p.description spec_status_desc,
    t.description spec_vr_status_desc,
    v.start_date, v.end_date,
    s.revision,
    s.grade_code grade_code,
    NULL resources,
    to_number(NULL) resource_instance_id,
    v.last_updated_by ,
    s.inventory_item_id,
    v.subinventory, v.locator_id
FROM GMD_INVENTORY_SPEC_VRS v ,
     GMD_SPECIFICATIONS_B s,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND v.spec_vr_id = lSpecVRId
UNION
SELECT v.spec_vr_id, s.spec_name , s.spec_vers, 'W' spec_type,
    v.organization_id,
    p.description spec_status_desc,
    t.description spec_vr_status_desc,
    v.start_date, v.end_date,
    s.revision,
    s.grade_code grade_code,
    NULL resources,
    to_number(NULL) resource_instance_id,
    v.last_updated_by ,
    s.inventory_item_id,
    NULL subinventory, NULL locator_id
FROM GMD_WIP_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND v.spec_vr_id = lSpecVRId
UNION
SELECT v.spec_vr_id, s.spec_name , s.spec_vers, 'C' spec_type,
    v.organization_id,
    p.description spec_status_desc,
    t.description spec_vr_status_desc,
    v.start_date, v.end_date,
    s.revision,
    s.grade_code grade_code,
    NULL resources,
    to_number(NULL) resource_instance_id,
    v.last_updated_by ,
    s.inventory_item_id,
    NULL subinventory, NULL locator_id
FROM GMD_CUSTOMER_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND v.spec_vr_id = lSpecVRId
UNION
SELECT v.spec_vr_id, s.spec_name , s.spec_vers, 'S' spec_type,
    v.organization_id,
    p.description spec_status_desc,
    t.description spec_vr_status_desc,
    v.start_date, v.end_date,
    s.revision,
    s.grade_code grade_code,
    NULL resources,
    to_number(NULL) resource_instance_id,
    v.last_updated_by ,
    s.inventory_item_id,
    NULL subinventory, NULL locator_id
FROM GMD_SUPPLIER_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND v.spec_vr_id = lSpecVRId
UNION
SELECT v.spec_vr_id, s.spec_name , s.spec_vers, v.rule_type spec_type,
    decode(rule_type,'R',v.resource_organization_id,'L',v.locator_organization_id,TO_NUMBER(NULL)) organization_id,
    p.description spec_status_desc,
    t.description spec_vr_status_desc,
    v.start_date, v.end_date,
    s.revision,
    s.grade_code grade_code,
    resources,
    resource_instance_id,
    v.last_updated_by ,
    TO_NUMBER(NULL),
    v.subinventory, v.locator_id
FROM GMD_MONITORING_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND v.spec_vr_id = lSpecVRId
UNION
SELECT v.spec_vr_id, s.spec_name , s.spec_vers, 'T' spec_type,
    NULL,
    p.description spec_status_desc,
    t.description spec_vr_status_desc,
    v.start_date, v.end_date,
    s.revision,
    s.grade_code grade_code,
    NULL resources,
    to_number(NULL) resource_instance_id,
    v.last_updated_by ,
    TO_NUMBER(NULL),
    NULL subinventory, NULL locator_id
FROM GMD_STABILITY_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND v.spec_vr_id = lSpecVRId;

   disp_attr_rec  get_disp_Attr%ROWTYPE;

/*================================================
   BUG#4912074 - Cursors to get additional data.
  ================================================*/

CURSOR get_org_data (v_org_id NUMBER) IS
SELECT a.organization_code, hou.name organization_name
FROM mtl_parameters a, hr_all_organization_units hou
WHERE
a.organization_id = v_org_id
AND  a.organization_id = hou.organization_id;

l_orgn_code           mtl_parameters.organization_code%TYPE;
l_orgn_name           hr_all_organization_units.name%TYPE;


CURSOR get_item_data (v_itemorg NUMBER, v_item_id NUMBER) IS
select concatenated_segments item_number, description item_description
FROM mtl_system_items_kfv
WHERE
organization_id = v_itemorg
AND inventory_item_id = v_item_id;

l_item_number     mtl_system_items_kfv.concatenated_segments%TYPE;
l_item_desc       mtl_system_items_kfv.description%TYPE;

CURSOR get_meaning (v_code VARCHAR2) IS
SELECT meaning
FROM gem_lookups
WHERE lookup_type = 'GMD_ERES_SOURCE'
AND lookup_code = v_code;

l_lookup_code     gem_lookups.meaning%TYPE;

CURSOR get_location (v_loc_id NUMBER) IS
SELECT concatenated_segments loc
FROM   mtl_item_locations_kfv
WHERE  inventory_location_id = v_loc_id;

l_location        mtl_item_locations_kfv.concatenated_segments%TYPE;

/*==============================================
   BUG#4912074 Replaced get_mont_disp_Attr
   using view gmd_all_spec_vrs for efficiency.
  ==============================================*/

cursor get_mont_disp_Attr IS
SELECT  s.spec_name, s.spec_vers, v.rule_type spec_type,
    t.description spec_vr_status_desc,
    p.description spec_status_desc,
    v.start_date, v.end_date,
    resources,
    resource_instance_id,
    v.last_updated_by ,
    v.subinventory SUBINV,
    src_type.meaning,
    locations.concatenated_segments LOC,
    a.organization_code,
    hou.name organization_name
FROM GMD_MONITORING_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S,
     GMD_QC_STATUS_TL p,
     GMD_QC_STATUS_TL t,
     GEM_LOOKUPS src_type  ,
     MTL_ITEM_LOCATIONS_KFV locations,
     MTL_PARAMETERS a,
     HR_ALL_ORGANIZATION_UNITS hou
WHERE V.SPEC_ID = S.SPEC_ID
  AND s.spec_status = p.status_code
  AND p.entity_type = 'S'
  AND p.language = USERENV('LANG')
  AND v.spec_vr_status = t.status_code
  AND t.entity_type = 'S'
  AND t.language = USERENV('LANG')
  AND src_type.lookup_type(+) = 'GMD_ERES_SOURCE'
  AND src_type.lookup_code(+) = spec_type
  AND locations.inventory_location_id(+) = v.locator_id
  AND a.organization_id(+) =
    decode(rule_type,'R',v.resource_organization_id,'L',v.locator_organization_id,TO_NUMBER(NULL))
  AND a.organization_id = hou.organization_id
  AND v.spec_vr_id = lSpecVRid;

   mont_disp_attr_rec  get_mont_disp_Attr%ROWTYPE;

   -- INVCONV, NSRIVAST, END

   cursor get_from_role is
     select nvl( text, '')
        from wf_Resources where name = 'WF_ADMIN_ROLE'
        and language = userenv('LANG')   ;

   l_from_role varchar2(2000);


  begin


    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('SpecVRApp');
       gmd_debug.put_line('Spec VR Id ' || lSpecVRId );
       gmd_debug.put_line('Start Status ' || lStartStatus);
       gmd_debug.put_line('Target Status ' || lTargetStatus);
    END IF;

        open get_from_role ;
        fetch get_from_role into l_from_role ;
        close get_from_role ;


    IF p_funcmode = 'RUN' THEN
        /* Find out which Spec type we are dealing with: item or monitor */
        open get_spec_type;
                fetch get_spec_type into l_spec_type;
        close get_spec_type;


      --
      -- clear All Approvals from AME
      -- following API removes previous instance of approval group from AME tables
      --
      ame_api.clearAllApprovals(applicationIdIn   => applicationId,
                              transactionIdIn   => lSpecVRId,
                              transactionTypeIn => transactionType);
      --
      -- Get the next approver who need to approve the trasaction
      --

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Getting approver ');
      END IF;

      ame_api.getNextApprover(applicationIdIn   => applicationId,
                            transactionIdIn   => lSpecVRId,
                            transactionTypeIn => transactionType,
                            nextApproverOut   => nextApprover);

      IF nextApprover.user_id  IS NULL and nextApprover.person_id IS NULL
      THEN

           IF (l_debug = 'Y') THEN
                gmd_debug.put_line('No approver required');
           END IF;

           --
           -- Means either no AME rule is matching for this transaction ID or Approver list is empty.
           -- change status of the object to target status
           --
          GMD_SPEC_GRP.change_status( p_table_name    => l_TABLE_NAME
                                , p_id            => lSpecVRId
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
          --
          --  We got the first approver from AME
          --

        IF (l_debug = 'Y') THEN
                gmd_debug.put_line('Approver required');
        END IF;

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
        GMD_SPEC_GRP.change_status( p_table_name    => l_TABLE_NAME
                                , p_id            => lSpecVRId
                                , p_source_status => lStartStatus
                                , p_target_status => lTargetStatus
                                , p_mode          => 'P'
                                , x_return_status => api_ret_status
                                , x_message       => api_err_mesg );
       IF api_ret_status = 'S' THEN
          -- Get attributes Required for display


        IF (l_debug = 'Y') THEN
                gmd_debug.put_line('Spec  Type ' || l_spec_type);
        END IF;


       /*==============================================
          BUG#4912074 Replaced spec_type of M with
          R or L.
         ==============================================*/
        if (l_spec_type in ('R','L')) then
                /* This is a monitoring Spec VR */
          open get_mont_disp_Attr;
          FETCH get_mont_disp_Attr INTO mont_disp_attr_rec;
          IF get_mont_disp_Attr%NOTFOUND THEN
            WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,FND_MESSAGE.GET_STRING('GMD','GMD_QC_INVALID_SPEC_VR_ID for Monitoring'));
            raise APPLICATION_ERROR;
          END IF;

          l_requester := GET_FND_USER_NAME(mont_disp_attr_rec.LAST_UPDATED_BY);
          close get_mont_disp_Attr;
        else
                /* This is an item spec VR */
          open get_disp_Attr;
          FETCH get_disp_Attr INTO disp_attr_rec;
          IF get_disp_Attr%NOTFOUND THEN
            WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,FND_MESSAGE.GET_STRING('GMD','GMD_QC_INVALID_SPEC_VR_ID'));
            raise APPLICATION_ERROR;
          END IF;

          l_requester := GET_FND_USER_NAME(disp_attr_rec.LAST_UPDATED_BY);
          close  get_disp_Attr;
        end if;


         /*====================================================
                 BUG#4912074 - get additional data.
           ====================================================*/

         IF (disp_attr_rec.organization_id IS NOT NULL) THEN
            OPEN get_org_data (disp_attr_rec.organization_id);
            FETCH get_org_data INTO l_orgn_code, l_orgn_name;
            IF (get_org_data%NOTFOUND) THEN
                l_orgn_code := NULL;
                l_orgn_name := NULL;
            END IF;
            CLOSE get_org_data;
         ELSE
             l_orgn_code := NULL;
             l_orgn_name := NULL;
         END IF;

         IF (disp_attr_rec.organization_id IS NOT NULL AND disp_attr_rec.inventory_item_id IS NOT NULL) THEN
            OPEN get_item_data (disp_attr_rec.organization_id, disp_attr_rec.inventory_item_id);
            FETCH get_item_data INTO l_item_number, l_item_desc;
            IF (get_item_data%NOTFOUND) THEN
                l_item_number := NULL;
                l_item_desc := NULL;
            END IF;
            CLOSE get_item_data;
         ELSE
             l_item_number := NULL;
             l_item_desc := NULL;
         END IF;

         IF (disp_attr_rec.spec_type IS NOT NULL) THEN
            OPEN get_meaning (disp_attr_rec.spec_type);
            FETCH get_meaning INTO l_lookup_code;
            IF (get_meaning%NOTFOUND) THEN
                l_lookup_code := NULL;
            END IF;
            CLOSE get_meaning;
         ELSE
             l_lookup_code := NULL;
         END IF;

         IF (disp_attr_rec.locator_id IS NOT NULL) THEN
            OPEN get_location (disp_attr_rec.locator_id);
            FETCH get_location INTO l_location;
            IF (get_location%NOTFOUND) THEN
                l_location := NULL;
            END IF;
            CLOSE get_location;
         ELSE
             l_location := NULL;
         END IF;

          lStartStatus_DESC := GMDQSPEC_APPROVAL_WF_PKG.GET_STATUS_MEANING(lStartStatus,'S');
          lTargetStatus_DESC:= GMDQSPEC_APPROVAL_WF_PKG.GET_STATUS_MEANING(lTargetStatus,'S');

           IF (l_debug = 'Y') THEN
                gmd_debug.put_line('Setting workflow attributes');
           END IF;

          /* Depending on whether the Spec VR is for an item or monitor, fill out the
                tokenized message and set it in the workflow */

          /*==============================================
             BUG#4912074 Replaced spec_type of M with
             R or L.  Added set of value for attribute
             RESOURCE.
            ==============================================*/

          if (l_spec_type in ('R','L')) then
                /* This is a monitoring Spec VR */
                  FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_APPROVAL_VR_MON');
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'RESOURCE',mont_disp_attr_rec.resources);
                  FND_MESSAGE.SET_TOKEN('RESOURCE', mont_disp_attr_rec.RESOURCES);
                  FND_MESSAGE.SET_TOKEN('RESOURCE_INSTANCE', mont_disp_attr_rec.RESOURCE_INSTANCE_ID);
                  FND_MESSAGE.SET_TOKEN('SUBINVENTORY', mont_disp_attr_rec.SUBINV);  -- INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('LOCATOR', mont_disp_attr_rec.LOC);      -- INVCONV, NSRIVAST


                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_NAME',mont_disp_attr_rec.SPEC_NAME);
                  wf_engine.setitemattrnumber(p_itemtype, p_itemkey,'SPEC_VERS',mont_disp_attr_rec.SPEC_VERS);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_STATUS',mont_disp_attr_rec.SPEC_STATUS_DESC);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SOURCE_TYPE',mont_disp_attr_rec.MEANING);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_STATUS',mont_disp_attr_rec.SPEC_VR_STATUS_DESC);
                  wf_engine.setitemattrdate(p_itemtype, p_itemkey,'EFFECTIVE_FROM_DATE',mont_disp_attr_rec.START_DATE);
                  wf_engine.setitemattrdate(p_itemtype, p_itemkey,'EFFECTIVE_TO_DATE',mont_disp_attr_rec.END_DATE );
                  --wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',mont_disp_attr_rec.ORGN_CODE);        -- INVCONV, NSRIVAST
                  --wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_NAME',mont_disp_attr_rec.ORGN_NAME);        -- INVCONV, NSRIVAST
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',mont_disp_attr_rec.ORGANIZATION_CODE);  -- INVCONV, NSRIVAST
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_NAME',mont_disp_attr_rec.ORGANIZATION_NAME);  -- INVCONV, NSRIVAST
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REQUESTER',l_requester);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'START_STATUS_DESC',lStartStatus_DESC);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS_DESC',lTargetStatus_DESC);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'APPROVER',l_userName);

                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SUBINVENTORY',mont_disp_attr_rec.SUBINV);  -- INVCONV, NSRIVAST
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'LOCATOR',mont_disp_attr_rec.LOC);         -- INVCONV, NSRIVAST


                  FND_MESSAGE.SET_TOKEN('SPEC_NAME', mont_disp_attr_rec.SPEC_NAME);
                  FND_MESSAGE.SET_TOKEN('SPEC_VERS', mont_disp_attr_rec.SPEC_VERS);
                  FND_MESSAGE.SET_TOKEN('SPEC_DESC', mont_disp_attr_rec.SPEC_STATUS_DESC);
                  FND_MESSAGE.SET_TOKEN('SPEC_STATUS', mont_disp_attr_rec.MEANING);
                  --FND_MESSAGE.SET_TOKEN('OWNER_ORGN_CODE', mont_disp_attr_rec.ORGN_CODE);            -- INVCONV, NSRIVAST
                  --FND_MESSAGE.SET_TOKEN('OWNER_ORGN_NAME', mont_disp_attr_rec.ORGN_NAME);            -- INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('OWNER_ORGN_CODE', mont_disp_attr_rec.ORGANIZATION_CODE);      -- INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('OWNER_ORGN_NAME', mont_disp_attr_rec.ORGANIZATION_NAME );     -- INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('REQUESTER', l_requester);
                  FND_MESSAGE.SET_TOKEN('START_STATUS_DESC', lStartStatus_DESC);
                  FND_MESSAGE.SET_TOKEN('TARGET_STATUS_DESC', lTargetStatus_DESC);
                  FND_MESSAGE.SET_TOKEN('APPROVER', l_userName);

          ELSE
                /* This is an Item Spec VR */
                  FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_APPROVAL_VR_ITEM');
                  /*=================================================
                     BUG#4912074 - Changed source of cursor data.
                    =================================================*/
                  FND_MESSAGE.SET_TOKEN('ITEM_NO', l_item_number);
                  FND_MESSAGE.SET_TOKEN('ITEM_DESC', l_item_desc);
                  FND_MESSAGE.SET_TOKEN('GRADE', disp_attr_rec.GRADE_CODE);          -- INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('SUBINVENTORY', disp_attr_rec.subinventory);  -- INVCONV, NSRIVAST
                  FND_MESSAGE.SET_TOKEN('LOCATOR', l_location);



                  WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => '#FROM_ROLE',
                                                  avalue => l_userName );

                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_NAME',disp_attr_rec.SPEC_NAME);
                  wf_engine.setitemattrnumber(p_itemtype, p_itemkey,'SPEC_VERS',disp_attr_rec.SPEC_VERS);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_STATUS',disp_attr_rec.SPEC_STATUS_DESC);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SOURCE_TYPE',l_lookup_code);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_STATUS',disp_attr_rec.SPEC_VR_STATUS_DESC);
                  wf_engine.setitemattrdate(p_itemtype, p_itemkey,'EFFECTIVE_FROM_DATE',disp_attr_rec.START_DATE);
                  wf_engine.setitemattrdate(p_itemtype, p_itemkey,'EFFECTIVE_TO_DATE',disp_attr_rec.END_DATE );
                  /*=======================================
                     BUG#4912074 Changed source of data.
                    =======================================*/
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',l_orgn_code);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_NAME',l_orgn_name);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'GRADE',disp_attr_rec.GRADE_CODE);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_NO',l_item_number);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_DESC',l_item_desc);

                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'REQUESTER',l_requester);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'START_STATUS_DESC',lStartStatus_DESC);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS_DESC',lTargetStatus_DESC);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'APPROVER',l_userName);

                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'ITEM_REVISION',disp_attr_rec.REVISION);  -- INVCONV, NSRIVAST
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'SUBINVENTORY',disp_attr_rec.subinventory);     -- INVCONV, NSRIVAST
                  /*=======================================
                     BUG#4912074 Changed source of data.
                    =======================================*/
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'OWNER_ORGN_CODE',l_orgn_code);
                  wf_engine.setitemattrtext(p_itemtype, p_itemkey,'LOCATOR',l_location);


                  FND_MESSAGE.SET_TOKEN('SPEC_NAME', disp_attr_rec.SPEC_NAME);
                  FND_MESSAGE.SET_TOKEN('SPEC_VERS', disp_attr_rec.SPEC_VERS);
                  FND_MESSAGE.SET_TOKEN('SPEC_DESC', disp_attr_rec.SPEC_STATUS_DESC);
                  /*=======================================
                     BUG#4912074 Changed source of data.
                    =======================================*/
                  FND_MESSAGE.SET_TOKEN('SPEC_STATUS', l_lookup_code);
                  FND_MESSAGE.SET_TOKEN('OWNER_ORGN_CODE', l_orgn_code);
                  FND_MESSAGE.SET_TOKEN('OWNER_ORGN_NAME', l_orgn_name);
                  FND_MESSAGE.SET_TOKEN('REQUESTER', l_requester);
                  FND_MESSAGE.SET_TOKEN('START_STATUS_DESC', lStartStatus_DESC);
                  FND_MESSAGE.SET_TOKEN('TARGET_STATUS_DESC', lTargetStatus_DESC);
                  FND_MESSAGE.SET_TOKEN('APPROVER', l_userName);

          END IF;



          /* Set the message attribute, MSG, in the workflow */
                  FND_MESSAGE.SET_TOKEN('MSG', FND_MESSAGE.GET() );

          l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

        WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                                       aname => 'GMDQSVRS_TIMEOUT',
                                               avalue => l_wf_timeout);
        WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                                                       aname => 'GMDQSVRS_MESG_CNT',
                                               avalue => 1);
          p_resultout := 'COMPLETE:Y';

        IF (l_debug = 'Y') THEN
                gmd_debug.put_line('Finished workflow attributes');
        END IF;

        ELSE
          WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,api_err_mesg );
          raise APPLICATION_ERROR;
        END IF;
      END IF;
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    WF_CORE.CONTEXT ('GMDQSPEC_APPROVAL_WF_PKG','is_approval_req',p_itemtype,p_itemkey,'Invalid Spec ID');
    raise;
  END IS_APPROVAL_REQ;


/**************************************************************************************
 *** This procedure is associated with GMDQSVRS_APP_COMMENT activity of the workflow **
 *** When user enters comments in response to a notification this procedure appends  **
 *** comments to internal variable so that full history can be shoed in notification **
 *** body.                                                                           **
 **************************************************************************************/

  PROCEDURE APPEND_COMMENTS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_comment       VARCHAR2(4000):= wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQSVRS_COMMENT');
      l_mesg_comment  VARCHAR2(4000):= wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQSVRS_DISP_COMMENT');
      l_performer     VARCHAR2(80)  := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDQSVRS_CURR_PERFORMER');
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
                                           aname => 'GMDQSVRS_DISP_COMMENT',
                                   avalue => l_mesg_comment);
           WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQSVRS_COMMENT',
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
 *** spec validity rule status to target status                                       **
 ***************************************************************************************/


  PROCEDURE ANY_MORE_APPROVERS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'EVENT_NAME');
    l_TABLE_NAME    varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TABLE_NAME');
    nextApprover ame_util.approverRecord;
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    lSpecVRId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_ID');
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
                            transactionIdIn   => lSpecVRId,
                            transactionTypeIn => transactionType,
                            nextApproverOut   => nextApprover);

      IF nextApprover.user_id  IS NULL and nextApprover.person_id IS NULL
      THEN
           --
           -- All Approvers are approved.
           -- change status of the object to target status
           --

          IF (l_debug = 'Y') THEN
                gmd_debug.put_line('No more approvers required');
          END IF;

          GMD_SPEC_GRP.change_status( p_table_name    => l_TABLE_NAME
                                , p_id            => lSpecVRId
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

        IF (l_debug = 'Y') THEN
                gmd_debug.put_line('There is still more approvers required');
        END IF;


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
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDQSVRS_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
                               aname => 'GMDQSVRS_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
                                           aname => 'GMDQSVRS_CURR_PERFORMER',
                                   avalue => l_approver);
       END IF;
END;

/****************************************************************************************
 *** This procedure is associated with GMDQSVRS_NOTI_NOT_RESP activity of the workflow **
 *** When approver fails to respond to notification defined in GMD: Workflow timeout   **
 *** profile this procedure sets spec Validity Rule status to start status and ends    **
 *** the workflow approval process.                                                    **
 ****************************************************************************************/

  PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    l_TABLE_NAME    varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TABLE_NAME');
    lSpecVRId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_ID');
    lStartStatus   Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'START_STATUS');
    lTargetStatus  Number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TARGET_STATUS');
    api_ret_status VARCHAR2(1);
    api_err_mesg   VARCHAR2(240);
  BEGIN
     IF p_funcmode = 'RUN' THEN
          GMD_SPEC_GRP.change_status( p_table_name    => l_TABLE_NAME
                                , p_id            => lSpecVRId
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
 *** This procedure is associated with GMDQSVRS_NOTI_REWORK activity of the workflow   **
 *** When approver rejects status change request procedure sets spec Validity rule     **
 *** status to rework status and ends the workflow approval process.                   **
 ****************************************************************************************/

  PROCEDURE REQ_REJECTED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
    applicationId number :=552;
    transactionType varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'EVENT_NAME');
    l_TABLE_NAME    varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'TABLE_NAME');
    nextApprover ame_util.approverRecord;
    lSpecVRId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_ID');
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
                                  transactionIdIn   => lSpecVRId,
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
                                         transactionIdIn   => lSpecVRId,
                                         transactionTypeIn => transactionType,
                                         ApproverIn   => nextApprover);
          END IF;
          GMD_SPEC_GRP.change_status( p_table_name    => l_TABLE_NAME
                                , p_id            => lSpecVRId
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
 *** This procedure is associated with GMDQSVRS_NOTI_APPROVED activity of the workflow **
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
    transactionType varchar2(50) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'EVENT_NAME');
    nextApprover ame_util.approverRecord;
    lSpecVRId number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SPEC_VR_ID');
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
                                  transactionIdIn   => lSpecVRId,
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
                                         transactionIdIn   => lSpecVRId,
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

 /***********************************************************************************************
  *** Following procedure is to raise Spec Validity Rule Status change approval business event **
  ***********************************************************************************************/

  PROCEDURE RAISE_SPEC_VR_APPR_EVENT(p_SPEC_VR_ID           NUMBER,
                                  P_EVENT_NAME        VARCHAR2,
                                  P_TABLE_NAME        VARCHAR2,
                                  p_START_STATUS      NUMBER,
                                  p_TARGET_STATUS     NUMBER) IS
    l_parameter_list wf_parameter_list_t :=wf_parameter_list_t( );
  BEGIN
    wf_log_pkg.wf_debug_flag:=TRUE;
    wf_event.AddParameterToList('SPEC_VR_ID', p_SPEC_VR_ID,l_parameter_list);
    wf_event.AddParameterToList('START_STATUS',p_START_STATUS ,l_parameter_list);
    wf_event.AddParameterToList('TARGET_STATUS',p_TARGET_STATUS ,l_parameter_list);
    wf_event.AddParameterToList('TABLE_NAME',P_TABLE_NAME ,l_parameter_list);
    wf_event.raise(p_event_name => P_EVENT_NAME,
                   p_event_key  => P_SPEC_VR_ID,
                   p_parameters => l_parameter_list);
    l_parameter_list.DELETE;
  END;
END GMDQSVRS_APPROVAL_WF_PKG;

/
