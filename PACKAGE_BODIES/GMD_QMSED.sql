--------------------------------------------------------
--  DDL for Package Body GMD_QMSED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QMSED" AS
/* $Header: GMDQMSEB.pls 120.5.12010000.2 2009/03/18 21:16:55 plowe ship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


PROCEDURE VERIFY_EVENT(
   /* procedure to verify event if the event is sample disposition or sample event disposition */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2)

   IS
 l_event_name varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');
 l_event_key varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

 l_current_approver varchar2(240);

 l_application_id number;
 l_transaction_type varchar2(100);
 l_user varchar2(32);
 Approver ame_util.approverRecord;
 l_item_no varchar2(240);
 l_item_desc varchar2(240);
 l_lot_no varchar2(240);
 l_sample_no varchar2(240);
 l_sample_plan varchar2(240);
 l_sample_disposition varchar2(240);
 l_sample_source varchar2(240);
 l_specification varchar2(240);
 l_validity_rule varchar2(240);
 l_validity_rule_version varchar2(240);
 l_sample_event_text varchar2(4000);
 l_sampling_event_id number;
 l_sample_desc varchar2(240);
 l_form varchar2(240);
 l_log varchar2(200);
 l_sample_event_count number ;
 l_sample_id number;
 l_item_revision varchar2(20);
 l_orgn_code varchar2(20);
 l_spec_vers varchar2(20);
 l_grade_code varchar2(150);
 -- Bug# 5221298
 l_spec_vr_id number;
 l_sampling_plan_id number;
 l_lpn_id NUMBER;    --RLNAGARA LPN ME 7027149
 l_lpn   VARCHAR2(240);   --RLNAGARA LPN ME 7027149

  cursor get_from_role is
     select nvl( text, '')
        from wf_Resources where name = 'WF_ADMIN_ROLE'   --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
        and language = userenv('LANG')   ;

 l_from_role varchar2(2000);

 BEGIN

    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('SampleDisposition');
       gmd_debug.put_line('Event  ' || l_event_name);
       gmd_debug.put_line('Event key  ' || l_event_key);
    END IF;


        open get_from_role ;
        fetch get_from_role into l_from_role ;
        close get_from_role ;

      /* Check which event has been raised */

    if l_event_name = 'oracle.apps.gmd.qm.sample.disposition' then
       l_transaction_type:='GMDQMSD';
       l_form := 'GMDQSMPL_EDIT_F:SAMPLE_ID="'||l_event_key||'"';

       -- B 3051565 PK changed the cursor to read Sample disposition from gmd_event_spec_disp

       /*SELECT A.SAMPLE_NO,A.SAMPLE_DESC,A.SAMPLING_EVENT_ID,A.REVISION,B.CONCATENATED_SEGMENTS,B.DESCRIPTION,
              A.LOT_NUMBER,GES.DISPOSITION,A.SOURCE,D.SPEC_NAME||' / '||to_char(D.SPEC_VERS),
    	      D.SPEC_VERS,D.GRADE_CODE, mp.organization_code
         INTO L_SAMPLE_NO,L_SAMPLE_DESC,l_sampling_Event_id,L_ITEM_REVISION,L_ITEM_NO,L_ITEM_DESC,
              L_LOT_NO,L_SAMPLE_DISPOSITION,L_SAMPLE_SOURCE,L_SPECIFICATION,
    	      L_SPEC_VERS, L_GRADE_CODE, L_ORGN_CODE
         FROM gmd_samples a,mtl_system_items_kfv b,
              gmd_sampling_events c,gmd_all_spec_vrs_vl d ,
              gmd_sampling_events gse,
              gmd_event_spec_disp ges,
              gmd_sample_spec_disp gss,
    	      mtl_parameters mp
         WHERE
              A.sample_id=l_event_key AND
              a.inventory_item_id=b.inventory_item_id AND
              a.sampling_event_id=c.sampling_event_id AND
              c.original_spec_vr_id=d.spec_vr_id AND
              a.sampling_event_id = gse.sampling_event_id AND
              gse.sampling_event_id = ges.sampling_event_id AND
              ges.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y' AND
              ges.event_Spec_disp_id = gss.event_spec_disp_id AND
              gss.sample_id = a.sample_id AND
              ges.delete_mark = 0 AND
    	      mp.organization_id = a.organization_id AND
              b.organization_id = a.organization_id;     --RLNAGARA added this condition as item is always bind to Organization in R12*/

        --Rewritten the above query as part of performance bug# 4916904
       /*SELECT A.SAMPLE_NO,A.SAMPLE_DESC,A.SAMPLING_EVENT_ID,A.REVISION,B.CONCATENATED_SEGMENTS,B.DESCRIPTION,
              A.LOT_NUMBER,GES.DISPOSITION,A.SOURCE,E.SPEC_NAME||' / '||to_char(E.SPEC_VERS),
    	      E.SPEC_VERS,E.GRADE_CODE, mp.organization_code
         INTO L_SAMPLE_NO,L_SAMPLE_DESC,l_sampling_Event_id,L_ITEM_REVISION,L_ITEM_NO,L_ITEM_DESC,
              L_LOT_NO,L_SAMPLE_DISPOSITION,L_SAMPLE_SOURCE,L_SPECIFICATION,
    	      L_SPEC_VERS, L_GRADE_CODE, L_ORGN_CODE
         FROM gmd_samples a,
              mtl_system_items_kfv b,
              gmd_sampling_events c,
              gmd_com_spec_vrs_vl d ,
              gmd_specifications e,
              gmd_sampling_events gse,
              gmd_event_spec_disp ges,
              gmd_sample_spec_disp gss,
    	      mtl_parameters mp
         WHERE
              A.sample_id=l_event_key AND
              a.inventory_item_id=b.inventory_item_id AND
              a.sampling_event_id=c.sampling_event_id AND
              c.original_spec_vr_id=d.spec_vr_id AND
              d.spec_id = e.spec_id AND
              a.sampling_event_id = gse.sampling_event_id AND
              gse.sampling_event_id = ges.sampling_event_id AND
              ges.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y' AND
              ges.event_Spec_disp_id = gss.event_spec_disp_id AND
              gss.sample_id = a.sample_id AND
              ges.delete_mark = 0 AND
    	      mp.organization_id = a.organization_id AND
              b.organization_id = a.organization_id;*/

         -- Rewritten the above query as part of performance Bug# 5221298
         SELECT
            a.sample_no,a.sample_desc,a.sampling_event_id,a.revision,b.concatenated_segments,b.description,
            a.lot_number,a.lpn_id,ges.disposition,a.source,e.spec_name||' / '||to_char(e.spec_vers),
            e.spec_vers,e.grade_code, mp.organization_code
	 INTO L_SAMPLE_NO,L_SAMPLE_DESC,l_sampling_Event_id,L_ITEM_REVISION,L_ITEM_NO,L_ITEM_DESC,
              L_LOT_NO,l_lpn_id,L_SAMPLE_DISPOSITION,L_SAMPLE_SOURCE,L_SPECIFICATION,
    	      L_SPEC_VERS, L_GRADE_CODE, L_ORGN_CODE
         FROM
            gmd_samples a,
            mtl_system_items_kfv b,
            gmd_specifications_b e,
            gmd_sampling_events gse,
            (SELECT ges.sampling_event_id , ges.disposition ,ges.spec_vr_id,ges.spec_id
               FROM gmd_event_spec_disp ges, gmd_sample_spec_disp gss
              WHERE spec_used_for_lot_attrib_ind = 'Y'
                AND  ges.event_spec_disp_id = gss.event_spec_disp_id
                AND ges.delete_mark = 0
                AND gss.sample_id = l_event_key ) ges,
            mtl_parameters mp
         WHERE a.sample_id = l_event_key AND
            a.inventory_item_id = b.inventory_item_id AND
            ges.spec_id = e.spec_id AND
            a.sampling_event_id = gse.sampling_event_id AND
            gse.sampling_event_id = ges.sampling_event_id AND
            mp.organization_id = a.organization_id AND
            b.organization_id = a.organization_id;


                SELECT meaning INTO l_sample_DISPOSITION FROM
                 gem_lookups WHERE LOOKUP_TYPE='GMD_QC_SAMPLE_DISP'
                             AND lookup_code=l_sample_disposition;

    ELSIF l_event_name = 'oracle.apps.gmd.qm.samplingevent.disposition' THEN

        /* Check to see the number of active samples in this sampling event */
        SELECT SAMPLE_ACTIVE_CNT INTO l_sample_event_count
        FROM gmd_Sampling_events
        WHERE sampling_event_id = l_event_key ;

        /* If more than one active sample then go to the
           Composite Results form; otherwise go to Samples Form */
        IF l_sample_event_count > 1 THEN
                l_form := 'GMDQCMPS_F:SAMPLING_EVENT_ID="'||l_event_key||'"';
        ELSE
                SELECT s.sample_id INTO  l_sample_id
                 FROM gmd_samples s,
                 gmd_event_spec_disp esd,
                 gmd_sample_spec_disp ssd
                 WHERE esd.sampling_event_id = l_event_key
                 AND esd.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y'
                 AND esd.sampling_event_id = s.sampling_event_id
                 AND esd. EVENT_SPEC_DISP_ID = ssd.EVENT_SPEC_DISP_ID
                 AND ssd.disposition NOT IN ('0RT', '7CN') ;

               l_form := 'GMDQSMPL_EDIT_F:SAMPLE_ID="'||l_sample_id||'"';
        END IF;


        l_transaction_type:='GMDQMSED';
        /* l_form := 'GMDQSMGP_F:SAMPLING_EVENT_ID="'||l_event_key||'"'; */
        /*SELECT c.CONCATENATED_SEGMENTS,c.DESCRIPTION,A.LOT_NUMBER,
               A.SOURCE,SPEC_NAME||' / '||to_char(SPEC_VERS),
               d.SAMPLING_PLAN_NAME||' / '||d.SAMPLING_PLAN_DESC ,b.revision,b.organization_code
          INTO L_ITEM_NO,L_ITEM_DESC,L_LOT_NO,
               L_SAMPLE_SOURCE,L_SPECIFICATION,L_SAMPLE_PLAN,l_item_revision,l_orgn_code
          FROM GMD_SAMPLING_EVENTS A
	      ,GMD_ALL_SPEC_VRS_VL B
	      ,MTL_SYSTEM_ITEMS_KFV C
	      ,GMD_SAMPLING_PLANS D
           WHERE a.original_spec_vr_id=b.SPEC_VR_ID AND
                 b.inventory_item_id=c.inventory_item_id AND
                 a.sampling_plan_id=d.sampling_plan_id(+) AND
                 a.sampling_event_id=l_event_key;*/

        --Rewritten the above query as part of performance bug# 4916904
        /*SELECT c.CONCATENATED_SEGMENTS, c.DESCRIPTION, A.LOT_NUMBER,
               A.SOURCE, e.SPEC_NAME||' / '||to_char(e.SPEC_VERS),
               d.SAMPLING_PLAN_NAME||' / '||d.SAMPLING_PLAN_DESC ,e.revision, f.organization_code
          INTO L_ITEM_NO,L_ITEM_DESC,L_LOT_NO,
               L_SAMPLE_SOURCE,L_SPECIFICATION,L_SAMPLE_PLAN,l_item_revision,l_orgn_code
          FROM GMD_SAMPLING_EVENTS A
	      ,GMD_COM_SPEC_VRS_VL B
	      ,MTL_SYSTEM_ITEMS_B_KFV C
	      ,GMD_SAMPLING_PLANS D
	      ,GMD_SPECIFICATIONS_B E
	      ,MTL_PARAMETERS F
           WHERE a.original_spec_vr_id=b.SPEC_VR_ID AND
                 b.spec_id            = e.spec_id AND
                 e.inventory_item_id=c.inventory_item_id AND
                 b.organization_id = f.organization_id(+) AND
                 a.sampling_plan_id=d.sampling_plan_id(+) AND
                 a.sampling_event_id= l_event_key;*/

        -- Rewritten the above query as part of performance bug# 5221298
	-- Split the above SQL into following 3 SQL statements
        select original_spec_vr_id, sampling_plan_id
        into l_spec_vr_id, l_sampling_plan_id
        from gmd_sampling_events
        where sampling_event_id = l_event_key;

        IF l_sampling_plan_id IS NOT NULL THEN
           select a.sampling_plan_name || ' / ' || b.sampling_plan_desc
           into l_sample_plan
           from gmd_sampling_plans_b a, gmd_sampling_plans_tl b
           where a.sampling_plan_id = b.sampling_plan_id
           and a.sampling_plan_id = l_sampling_plan_id
           and b.language = userenv('LANG');
	END IF;

        select c.concatenated_segments, c.description, a.lot_number,a.lpn_id,
               a.source, e.spec_name||' / '||to_char(e.spec_vers),
               e.revision, f.organization_code
          INTO l_item_no,l_item_desc,l_lot_no,l_lpn_id,
               l_sample_source,l_specification,l_item_revision,l_orgn_code
          from gmd_sampling_events a
               ,gmd_com_spec_vrs_vl b
               ,mtl_system_items_b_kfv c
               ,gmd_specifications_b e
               ,mtl_parameters f
         where a.original_spec_vr_id = b.spec_vr_id and
               b.spec_id            = e.spec_id and
               e.inventory_item_id = c.inventory_item_id and
	       e.owner_organization_id = c.organization_id and  --RLNAGARA B5714223 Added this condition
               b.organization_id = f.organization_id(+) and
               a.sampling_event_id = l_event_key and
	       b.spec_vr_id = l_spec_vr_id;

     ELSIF l_event_name = 'oracle.apps.gmd.qm.compositeresults' THEN
        l_log:='Event is composite Results';
        l_transaction_type:='GMDQMSCR';
        /* l_form := 'GMDQSMGP_F:SAMPLING_EVENT_ID="'||l_event_key||'"'; */
        l_form := 'GMDQCMPS_F:SAMPLING_EVENT_ID="'||l_event_key||'"';
        /*SELECT c.CONCATENATED_SEGMENTS,c.DESCRIPTION,A.LOT_NUMBER,A.SOURCE,SPEC_NAME||' / '||to_char(SPEC_VERS),
               d.SAMPLING_PLAN_NAME||' / '||d.SAMPLING_PLAN_DESC ,b.revision,b.organization_code
          INTO L_ITEM_NO,L_ITEM_DESC,L_LOT_NO,L_SAMPLE_SOURCE,L_SPECIFICATION,L_SAMPLE_PLAN ,l_item_revision,l_orgn_code
          FROM GMD_SAMPLING_EVENTS A
	      ,GMD_ALL_SPEC_VRS_VL B
	      ,MTL_SYSTEM_ITEMS_KFV C
	      ,GMD_SAMPLING_PLANS D
           WHERE a.original_spec_vr_id=b.SPEC_VR_ID AND
                 b.inventory_item_id=c.inventory_item_id AND
                 a.sampling_plan_id=d.sampling_plan_id(+) AND
                 a.sampling_event_id=l_event_key;*/

        --Rewritten the above query as part of performance bug# 4916904
        /* SELECT c.CONCATENATED_SEGMENTS,c.DESCRIPTION,A.LOT_NUMBER,A.SOURCE,E.SPEC_NAME||' / '||to_char(E.SPEC_VERS),
               d.SAMPLING_PLAN_NAME||' / '||d.SAMPLING_PLAN_DESC ,e.revision,f.organization_code
          INTO L_ITEM_NO,L_ITEM_DESC,L_LOT_NO,L_SAMPLE_SOURCE,L_SPECIFICATION,L_SAMPLE_PLAN ,l_item_revision,l_orgn_code
          FROM GMD_SAMPLING_EVENTS A
	      ,GMD_COM_SPEC_VRS_VL B
	      ,MTL_SYSTEM_ITEMS_B_KFV C
	      ,GMD_SAMPLING_PLANS D
	      ,GMD_SPECIFICATIONS_B E
	      ,MTL_PARAMETERS F
           WHERE a.original_spec_vr_id=b.SPEC_VR_ID AND
                 b.spec_id            = e.spec_id AND
                 e.inventory_item_id=c.inventory_item_id AND
                 b.organization_id = f.organization_id(+) AND
                 a.sampling_plan_id=d.sampling_plan_id(+) AND
                 a.sampling_event_id= l_event_key; */

        -- Rewritten the above query as part of performance bug# 5221298
	-- Split the above SQL into following 3 SQL statements
        select original_spec_vr_id, sampling_plan_id
        into l_spec_vr_id, l_sampling_plan_id
        from gmd_sampling_events
        where sampling_event_id = l_event_key;

        IF l_sampling_plan_id IS NOT NULL THEN
           select a.sampling_plan_name || ' / ' || b.sampling_plan_desc
           into l_sample_plan
           from gmd_sampling_plans_b a, gmd_sampling_plans_tl b
           where a.sampling_plan_id = b.sampling_plan_id
           and a.sampling_plan_id = l_sampling_plan_id
           and b.language = userenv('LANG');
	END IF;

        select c.concatenated_segments, c.description, a.lot_number,a.lpn_id,a.source, e.spec_name||' / '||to_char(e.spec_vers),
               e.revision, f.organization_code
          INTO l_item_no,l_item_desc,l_lot_no,l_lpn_id,l_sample_source,l_specification,
	       l_item_revision,l_orgn_code
          from gmd_sampling_events a
               ,gmd_com_spec_vrs_vl b
               ,mtl_system_items_b_kfv c
               ,gmd_specifications_b e
               ,mtl_parameters f
         where a.original_spec_vr_id = b.spec_vr_id and
               b.spec_id            = e.spec_id and
               e.inventory_item_id = c.inventory_item_id and
	       e.owner_organization_id = c.organization_id and  --RLNAGARA B5714223 Added this condition
               b.organization_id = f.organization_id(+) and
               a.sampling_event_id = l_event_key and
	       b.spec_vr_id = l_spec_vr_id;

    END IF;
           l_log:='Resolving Lookups';
           /* Resolve Lookups */
              SELECT meaning INTO l_sample_source FROM
                 gem_lookups WHERE LOOKUP_TYPE='GMD_QC_SOURCE'
                             AND lookup_code=l_sample_source;

        l_log:='Resolved Lookups';

      --RLNAGARA LPN ME 7027149 start
      IF l_lpn_id IS NOT NULL THEN
       select license_plate_number INTO l_lpn
       from wms_license_plate_numbers
       where lpn_id = l_lpn_id;
      ELSE
       l_lpn := NULL;
      END IF;
      --RLNAGARA LPN ME 7027149 start

      /* Get First Approver */
        /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Ckecking approvers ');
      END IF;

      ame_api.clearAllApprovals(applicationIdIn => l_application_id,
                               transactionIdIn => l_event_key,
                               transactionTypeIn => l_transaction_type);

       l_log:='Approvers Cleared';
       ame_api.getNextApprover(applicationIdIn => l_application_id,
                              transactionIdIn => l_event_key,
                              transactionTypeIn => l_transaction_type,
                              nextApproverOut => Approver);
       l_log:='Approver : '||Approver.user_id;

     if(Approver.user_id is null and Approver.person_id is null) then
       /* No Approval Required */
        P_resultout:='COMPLETE:NO_WORKFLOW';
        IF (l_debug = 'Y') THEN
                 gmd_debug.put_line('No approvers ');
        END IF;
        return;
     end if;

      if(Approver.person_id is null) then
        select user_name into l_user from fnd_user
         where user_id=Approver.user_id;
      else
        /* select user_name into l_user from fnd_user a,per_all_people b
        where b.person_id=Approver.person_id and
        a.employee_id is not null and
        a.employee_id = b.person_id; */

        -- Rewritten the above query as part of performance bug# 5221298
	/*select user_name into l_user from fnd_user a
         where a.employee_id = Approver.person_id
           and a.employee_id is not null
           and exists (select 1 from per_all_people where person_id = Approver.person_id);*/

	-- RLNAGARA B5714223 Replaced the above query with the below query.
        select user_name into l_user from fnd_user
        where user_id=ame_util.personidtouserid (approver.person_id);

      end if;

         /* Set the User Attribute */

        IF (l_debug = 'Y') THEN
                 gmd_debug.put_line('Setting up workflow attributes ');
        END IF;

        WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'CURRENT_APPROVER',
                                                  avalue => l_user);
       /* Set All other Attributes */

        WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'APPS_FORM',
                                                  avalue =>l_form );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'ORGN_CODE',
                                                  avalue =>l_orgn_code);
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'ITEM_NO',
                                                  avalue =>l_item_no );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'ITEM_REVISION',
                                                  avalue =>l_item_revision );
       WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'ITEM_DESC',
                                                  avalue =>l_item_desc );
       WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'LOT_NO',
                                                  avalue =>l_lot_no );
       --RLNAGARA LPN ME 7027149
       WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'LPN',
                                                  avalue =>l_lpn );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SAMPLE_NO',
                                                  avalue =>l_sample_no );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SAMPLE_DESC',
                                                  avalue =>l_sample_desc );
       WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SAMPLE_PLAN',
                                                  avalue =>l_sample_plan );
       WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SAMPLE_DISPOSITION',
                                                  avalue =>l_sample_disposition );
       WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SAMPLE_SOURCE',
                                                  avalue =>l_sample_SOURCE );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SPECIFICATION',
                                                  avalue =>l_SPECIFICATION );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'SPECIFICATION_VERSION',
                                                  avalue =>l_spec_vers );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'GRADE_CODE',
                                                  avalue =>l_grade_code );
      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => '#FROM_ROLE',
                                                  avalue =>l_from_role );

      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'AME_TRANS',
                                                  avalue =>l_transaction_type );

      P_resultout:='COMPLETE:'||l_transaction_type;
      /* As this a pure FYI notification we will set the approer to approve status */
          Approver.approval_status := ame_util.approvedStatus;
          ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);


  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMSED','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
      raise;

  END VERIFY_EVENT;

PROCEDURE CHECK_NEXT_APPROVER(
   /* procedure to verify event if the event is sample disposition or sample event disposition */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2)

   IS
 l_event_name varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');
 l_event_key varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

 l_current_approver varchar2(240);

 l_application_id number;
 l_transaction_type varchar2(100):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'AME_TRANS');
 l_user varchar2(32);
 Approver ame_util.approverRecord;
 l_item_no varchar2(240);
 l_item_desc varchar2(240);
 l_lot_no varchar2(240);
 l_sublot_no varchar2(240);
 l_sample_no varchar2(240);
 l_sample_plan varchar2(240);
 l_sample_disposition varchar2(240);
 l_sample_source varchar2(240);
 l_specification varchar2(240);
 l_validity_rule varchar2(240);
 l_validity_rule_version varchar2(240);
 l_sample_event_text varchar2(4000);
 l_sampling_event_id number;
 l_form varchar2(240);
 BEGIN




      /* Get Next Approver */
        /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

       ame_api.getNextApprover(applicationIdIn => l_application_id,
                              transactionIdIn => l_event_key,
                              transactionTypeIn => l_transaction_type,
                              nextApproverOut => Approver);

     if(Approver.user_id is null and Approver.person_id is null) then
       /* No Approval Required */
        P_resultout:='COMPLETE:N';
     else
       if(Approver.person_id is null) then
         select user_name into l_user from fnd_user
           where user_id=Approver.user_id;
       else
         /* select user_name into l_user from fnd_user a,per_all_people b
          where
           b.person_id=Approver.person_id and
           a.employee_id is not null and
           a.employee_id = b.person_id; */

	 -- Rewritten the above query as part of performance bug# 5221298
	 /*select user_name into l_user from fnd_user a
          where a.employee_id = Approver.person_id
            and a.employee_id is not null
            and exists (select 1 from per_all_people where person_id = Approver.person_id);*/

       --Rewritten the above query as part of fix Bug No.7656325

          select user_name into l_user from fnd_user
          where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);

        end if;

         /* Set the User Attribute */

               WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                  aname => 'CURRENT_APPROVER',
                                                  avalue => l_user);
         P_resultout:='COMPLETE:Y';
          Approver.approval_status := ame_util.approvedStatus;
          ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);
     end if;
  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMSED','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;



END GMD_QMSED;

/
