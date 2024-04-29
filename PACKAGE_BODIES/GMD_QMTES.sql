--------------------------------------------------------
--  DDL for Package Body GMD_QMTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QMTES" AS
/* $Header: GMDQMTEB.pls 120.7.12010000.3 2009/09/17 07:01:11 kannavar ship $ */


  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE VERIFY_EVENT(
   /* procedure to verify event and send out notifications*/
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
 l_transaction_type varchar2(100):='GMDQMPF';
 l_user varchar2(32);
 Approver ame_util.approverRecord;
 l_test_id number:=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'TEST_ID');

   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;
   l_item_no varchar2(240);
   l_item_desc varchar2(240);
   l_item_um varchar2(32);
   l_parent_lot varchar2(240);   --RLNAGARA B5714214 Added parent_lot
   l_lot_no varchar2(240);
   l_lpn   VARCHAR2(240);      --RLNAGARA LPN ME 7027149
   l_result_id varchar2(240);
   l_test_code varchar2(240);
   l_test_desc varchar2(240);
   l_test_class varchar2(240);
   l_test_method_code varchar2(240);
   l_test_method_desc varchar2(240);
   l_resources varchar2(240);
   l_test_replicate varchar2(240);
   l_qc_lab_orgn_code varchar2(240);
   l_qc_lab_org_id   number;
   l_sample_id varchar2(240);
   l_sample_no varchar2(240);
   l_sample_desc varchar2(240);
   l_days number ;
   l_hours number ;
   l_minutes number ;
   l_seconds number ;
   l_testbydate varchar2(240);

	L_ITEM_REVISION varchar2(240);
	l_SUBINVENTORY varchar2(240);
	l_LOCATOR varchar2(240);
	l_planned_resource varchar2(240);
	l_planned_Result_date varchar2(240);

 --RLNAGARA B5738147 start
  l_source VARCHAR2(1);
	l_source_subinv varchar2(240);
	l_source_loc varchar2(240);
 --RLNAGARA B5738147 end

--RLNAGARA B5714214 Removed the reference to table MTL_LOT_NUMBERS and retrieved the lot info from gmd_samples table.
-- Also added parent_lot_number
 /* This Cusror Will Pick up all Test Details for a Given Sample */
Cursor C1 is
SELECT D.CONCATENATED_SEGMENTS,D.description,D.primary_uom_code,C.PARENT_LOT_NUMBER,C.LOT_NUMBER, wlpn.license_plate_number lpn,
       to_char(GR.RESULT_ID),A.TEST_CODE,A.TEST_DESC,A.TEST_CLASS,
       B.TEST_METHOD_CODE, B.TEST_METHOD_DESC,B.RESOURCES,B.TEST_REPLICATE,
	     C.LAB_ORGANIZATION_ID, C.SAMPLE_ID,C.SAMPLE_NO,C.SAMPLE_DESC,
	     C.SUBINVENTORY, gr.test_by_date, gr.planned_Resource, gr.planned_result_date,
       MIL.concatenated_segments, c.revision,
       c.source_subinventory, MIL1.concatenated_segments,c.source  --RLNAGARA B5738147
		from    GMD_RESULTS GR,
	        GMD_QC_TESTS_VL A,
	        GMD_TEST_METHODS B,
	        GMD_SAMPLES C,
	        mtl_system_items_kfv D,
--        mtl_lot_numbers E,
          mtl_parameters MP,
          mtl_item_locations_kfv MIL,
          mtl_item_locations_kfv MIL1,             --RLNAGARA B5738147
	  wms_license_plate_numbers wlpn   --RLNAGARA LPN ME 7027149
	WHERE       GR.SAMPLE_ID = l_event_key AND
	            GR.SAMPLE_ID=C.SAMPLE_ID AND
	            NVL(L_TEST_ID,GR.TEST_ID)=A.TEST_ID AND
	            A.TEST_METHOD_ID=B.TEST_METHOD_ID AND
	            C.ORGANIZATION_ID=D.ORGANIZATION_ID AND
--	            C.INVENTORY_ITEM_ID=E.INVENTORY_ITEM_ID(+) AND
	            C.INVENTORY_ITEM_ID= D.INVENTORY_ITEM_ID AND
--	            C.ORGANIZATION_ID = E.ORGANIZATION_ID AND
--	            C.LOT_NUMBER = E.LOT_NUMBER AND
                    C.organization_id = mp.organization_id AND
                    MIL.organization_id(+) = C.organization_id AND
                    MIL.inventory_location_id(+) = C.locator_id AND
                  MIL1.organization_id(+) = C.organization_id AND           --RLNAGARA B5738147
                  MIL1.inventory_location_id(+) = C.source_locator_id AND   --RLNAGARA B5738147
		  wlpn.lpn_id(+) = c.lpn_id;     -- RLNAGARA LPN ME 7027149


	cursor get_from_role is
	  select nvl( text, '')
	from wf_Resources where name = 'WF_ADMIN_ROLE'
	and language = userenv('LANG')   ;


  CURSOR GET_LAB_ORG IS
   SELECT organization_code
   FROM   mtl_parameters
   WHERE  organization_id = l_qc_lab_org_id;

  l_from_role varchar2(240);
  l_sequence_id number;

 BEGIN

    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('PerformTest');
       gmd_debug.put_line('Event Name ' || l_event_name);
       gmd_debug.put_line('Event Key ' || l_event_key);
    END IF;

	open get_from_role ;
	fetch get_from_role into l_from_role ;
	close get_from_role ;


   IF P_FUNCMODE='RUN' THEN
     /* Get application_id from FND_APPLICATION */
      select application_id into l_application_id
        from fnd_application where application_short_name='GMD';

      /* Check which event has been raised */
      wf_log_pkg.string(6, 'Dummy','Entered Test Transactions with event_key '||l_event_key);

         /*Figure out if all the batch_steps are covered for sampple creation */

      OPEN C1;
      LOOP
         wf_log_pkg.string(6, 'Dummy','Before Fetching the values. Inside the Loop');
         Fetch C1 into L_ITEM_NO,L_ITEM_DESC,L_ITEM_UM,L_PARENT_LOT,L_LOT_NO,l_lpn,L_RESULT_ID,L_TEST_CODE,L_TEST_DESC, --RLNAGARA B5714214 Added l_parent_lot
              L_TEST_CLASS,L_TEST_METHOD_CODE,L_TEST_METHOD_DESC,L_RESOURCES,L_TEST_REPLICATE,
              l_qc_lab_org_id, L_SAMPLE_ID,L_SAMPLE_NO,L_SAMPLE_DESC,
	      l_SUBINVENTORY, l_testbydate,l_planned_resource,l_planned_Result_date, l_LOCATOR,
              L_ITEM_REVISION,l_source_subinv,l_source_loc,l_source;      --RLNAGARA B5738147
         EXIT when c1%notfound;
 --RLNAGARA B5738147 start
        IF l_source ='W' THEN
          	l_SUBINVENTORY := l_source_subinv;
          	l_LOCATOR := l_source_loc;
        END IF;
 --RLNAGARA B5738147 end

         OPEN GET_LAB_ORG;
         Fetch GET_LAB_ORG into l_qc_lab_orgn_code;
         IF (GET_LAB_ORG%NOTFOUND) THEN
            l_qc_lab_orgn_code := NULL;
         END IF;
         CLOSE GET_LAB_ORG;


             	/* Set Form Attribute to the sampling event */
         l_form := 'GMDQRSLT_EDIT_F:SAMPLE_ID="'||l_sample_id||'"';


         IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Checking for approvers ');
         END IF;

              	/* Start the Workflow for the Given Combination */
         ame_api.clearAllApprovals(applicationIdIn =>   l_application_id,
                                        transactionIdIn =>   l_result_id,
                                        transactionTypeIn => l_transaction_type);
         wf_log_pkg.string(6, 'Dummy','Approvers Cleared');
         ame_api.getNextApprover(applicationIdIn => l_application_id,
                                      transactionIdIn => l_result_id,
                                      transactionTypeIn => l_transaction_type,
                                      nextApproverOut => Approver);

         if(Approver.user_id is null and Approver.person_id is null) then
                  /* No Approval Required */
            NULL;
-- Bug #3801988 (JKB) Changed EXIT to NULL above and realigned code below so it is inside the ELSE.
         else

      	    IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Approvers Found');
      	    END IF;

      	    if(Approver.person_id is null) then
               select user_name into l_user from fnd_user
        			 where user_id=Approver.user_id;
      	    else
               select user_name into l_user from fnd_user
      	       where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
      	    end if;


            Select MTL_MATERIAL_STATUS_HISTORY_S.nextval
		Into l_sequence_id
		From dual;


      	    l_itemtype:='GMDQMTST';
      	    l_itemkey:=l_event_key||'-'||l_result_id||'-'
                               ||to_char(sysdate,'dd/mm/yy hh:mi:ss')||'-'||l_sequence_id;
      	    l_workflow_process:='GMDQMTST_SUB_PROCESS';
	--insert into rg_debug(vdata) values(l_itemkey);

  	/* Start the subprocess now instead of earlier to fix the cancelled FYI
		notifications */
      	    WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                                     itemkey => l_itemkey,
                                     process => l_Workflow_Process) ;


         /* Set the User Attribute */

      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'CURRENT_APPROVER',
         					  avalue => l_user);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'APPS_FORM',
         					  avalue =>l_form );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => p_itemkey,
        	 					  aname => 'EVENT_NAME',
         						  avalue =>l_event_name );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'EVENT_KEY',
         						  avalue =>l_result_id );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_NO',
         						  avalue =>l_item_no );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_REVISION',
         						  avalue =>l_item_revision );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_DESC',
         						  avalue =>l_item_desc );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_UM',
         						  avalue =>l_item_um );
            --RLNAGARA B5714214 Added parent_lot to the notification also.
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'PARENT_LOT',
        						  avalue =>l_parent_lot );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'LOT_NO',
         						  avalue =>l_lot_no );
            --RLNAGARA LPN ME 7027149
	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'LPN',
         						  avalue =>l_lpn );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_CODE',
         						  avalue =>l_test_code );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_DESC',
         						  avalue =>l_test_desc );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_CLASS',
         						  avalue =>l_test_class );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_METHOD_CODE',
         						  avalue =>l_test_method_Code );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_METHOD_DESC',
         						  avalue =>l_test_method_desc );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_REPLICATE',
         						  avalue =>l_test_replicate );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'RESOURCES',
         						  avalue =>l_resources );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'QC_LAB_ORGN_CODE',
         						  avalue =>l_qc_lab_orgn_code );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'SAMPLE_NO',
         					  avalue =>l_sample_no );
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'SAMPLE_DESC',
         					  avalue =>l_sample_desc);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'AME_TRANS',
         					  avalue =>l_transaction_type);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'DAYS',
         					  avalue =>l_days);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'HOURS',
         					  avalue =>l_hours);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'MINUTES',
         					  avalue =>l_minutes);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'SECONDS',
         					  avalue =>l_seconds);
      	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'TEST_BY_DATE',
         					  avalue =>l_testbydate);
     	  -- WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey, aname => '#FROM_ROLE',avalue => l_from_role );
	-- SCHANDRU INVCONV START
	    wf_engine.setitemattrtext(itemtype => l_itemtype,itemkey => l_itemkey,
						  aname =>'SUBINVENTORY',
						   avalue =>l_SUBINVENTORY);
	    wf_engine.setitemattrtext(itemtype => l_itemtype,itemkey => l_itemkey,
						  aname => 'LOCATOR',
						  avalue => l_LOCATOR);
	    wf_engine.setitemattrtext(itemtype => l_itemtype, itemkey =>l_itemkey,
						  aname =>'PLANNED_RESOURCE',
						  avalue =>l_planned_resource);
            wf_engine.setitemattrtext(itemtype => l_itemtype,itemkey => l_itemkey,
						  aname =>'PLANNED_RESULT_DATE',
						  avalue => l_planned_Result_date);
	-- SCHANDRU INVCONV END
      	    WF_ENGINE.SETITEMPARENT(itemtype =>l_itemtype,itemkey =>l_itemkey,
                                         parent_itemtype => p_itemtype,
                                         parent_itemkey=> p_itemkey,
                                         parent_context=> NULL);

                   /* start the Workflow process */
      	    wf_log_pkg.string(6, 'Dummy','Starting Process');


       /* As this a pure FYI notification we will set the approer to approve status */
      	    Approver.approval_status := ame_util.approvedStatus;
      	    ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_result_id,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);


      	    WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);


      	    wf_log_pkg.string(6, 'Dummy','Child Process Created and current approver is '||l_user);

         end if;

      END LOOP;
      CLOSE C1;
   END IF;
   p_resultout:='COMPLETE:';


  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMTES','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
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
	  select user_name into l_user from fnd_user
          where
          user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
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
      WF_CORE.CONTEXT ('GMD_QMTES','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;
END GMD_QMTES;

/
