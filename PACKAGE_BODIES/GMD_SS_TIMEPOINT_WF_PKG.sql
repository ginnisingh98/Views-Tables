--------------------------------------------------------
--  DDL for Package Body GMD_SS_TIMEPOINT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_TIMEPOINT_WF_PKG" AS
/* $Header: GMDQSTTB.pls 120.4 2006/12/05 16:07:45 rlnagara noship $ */



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
   l_transaction_type varchar2(100):='GMDQM_STABILITY_TEST';
   l_user varchar2(32);
   Approver ame_util.approverRecord;

   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;
   l_item_no varchar2(240);
   l_item_desc varchar2(240);
   l_item_revision varchar2(3);
   l_item_um varchar2(32);
   l_study varchar2(240);
   l_study_desc varchar2(240);
   l_recipe_no varchar2(240);
   l_recipe_vers varchar2(240);
   l_status varchar2(240);
   l_Sched_date varchar2(240);
   l_plant varchar2(240);
   l_sample_id varchar2(240);
   l_sample_no varchar2(240);
   l_sample_desc varchar2(240);
   l_sample_type varchar2(240);
   l_resource_desc varchar2(240);
   l_resource_num number ;
   l_batch_no varchar2(240);
   l_storage_subinventory varchar2(10);
   l_storage_locator varchar2(240);
   l_storage_spec varchar2(240);
   l_storage_spec_vers varchar2(240);
   l_resource varchar2(240);
   l_formula varchar2(240);
   l_formula_vers varchar2(240);
   l_package varchar2(240);
   l_sample_qty varchar2(240);
   l_sample_uom varchar2(240);
   l_warehouse varchar2(240);
   l_location varchar2(240);
   l_variant_no varchar2(240);
   l_study_date DATE;                       --RLNAGARA Bug3583790  Changed from VARCHAR2 to DATE
   l_sample_event_id varchar2(240);
   l_sample_temp varchar2(240);
   l_owner number;
   l_owner_used number := 0;
   l_time_name varchar2(240);
   l_organization varchar2(3);

--Cursor changed for Inventory convergence
--RLNAGARA Bug 3583790 select sample_qty instead of samples_per_time_point
--also h.storage_spec_id should be compared and not c.spec_id. Hence changed.

cursor C1 is
select  distinct k.organization_code, b.meaning, e.ss_no, h.variant_no,f.description,
   h.sample_qty, h.storage_subinventory, j.concatenated_segments storage_locator,
   h.resources, i.spec_name, i.spec_vers, c.scheduled_date,
   d.concatenated_segments item_no, d.description item_desc1, e.revision,
   c.sampling_event_id, e.owner , c.name
 from   gmd_ss_material_sources a,
        gmd_Qc_status b,
        gmd_ss_time_points c,
        mtl_system_items_b_kfv d,
        gmd_stability_studies_b e ,
        gmd_stability_studies_tl f ,
        gmd_ss_variants h,
        gmd_specifications i,
        mtl_item_locations_kfv j,
        mtl_parameters k
 where  c.time_point_id = l_event_key
       and c.variant_id = h.variant_id
       and h.material_source_id = a.source_id
       and a.ss_id = e.ss_id
       and d.inventory_item_id = e.inventory_item_id
       and d.organization_id = e.organization_id
       and h.material_source_id = a.source_id
       and h.storage_spec_id = i.spec_id
       and e.ss_id = f.ss_id
       and b.entity_type = 'STABILITY'
       and b.status_code = e.status
       and h.storage_locator_id = j.inventory_location_id(+)
       and h.storage_organization_id = j.organization_id(+)
       and k.organization_id = e.organization_id
       and f.language = userenv('LANG');

-- JD to C1 added organization match on mtl_item_locations_kfv and
-- outer join.
-- added language to gmd_stability_studies_tl
-- 10/20/2005


Cursor C2 (se_id NUMBER) is
  select sample_no from gmd_samples
  where sampling_event_id = se_id ;

  cursor get_from_role is
     select nvl( text, '')
	from wf_Resources where name = 'WF_ADMIN_ROLE'     --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
        AND language = userenv('LANG');   -- Added 10/20/2005

  l_from_role varchar2(240);

 BEGIN

     IF (l_debug = 'Y') THEN
 	      gmd_debug.log_initialize('Timepoint');
     END IF;

     IF (l_debug = 'Y') THEN
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
      wf_log_pkg.string(6, 'Dummy','Entered Stability Study Batch Creation '||l_event_key);



          OPEN C1;
             	Fetch C1 into l_organization, l_status, l_study,l_variant_no, l_study_desc,
			l_sample_qty, l_storage_subinventory, l_storage_locator,
			l_resource, l_storage_spec, l_storage_spec_vers,
			l_study_date, l_item_no, l_item_desc , l_item_revision, l_sample_event_id,
			l_owner, l_time_name;

		          OPEN C2 (l_sample_event_id );
				Loop
 				  fetch C2 into l_sample_temp;
				exit when c2%notfound;
                                l_sample_no := l_sample_no || ' ' || l_sample_temp;
				end loop;
 			  CLOSE C2;


             	/* Set Form Attribute to the sampling event */
--             	l_form := 'GMDQSMPL_EDIT_F:SAMPLING_EVENT_ID="'||l_sample_event_id||'"';
             	l_form := 'GMDQSAMPLES_F:SAMPLING_EVENT_ID="'||l_sample_event_id||'"';

              	/* Start the Workflow for the Given Combination */
		IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Getting AME approver');
	        END IF;

              	ame_api.clearAllApprovals(applicationIdIn =>   l_application_id,
                                        transactionIdIn =>   l_event_key,
                                        transactionTypeIn => l_transaction_type);

              	wf_log_pkg.string(6, 'Dummy','Approvers Cleared');
              	ame_api.getNextApprover(applicationIdIn => l_application_id,
                                      transactionIdIn => l_event_key,
                                      transactionTypeIn => l_transaction_type,
                                      nextApproverOut => Approver);

      		if(Approver.user_id is null and Approver.person_id is null) then
       			/* No Approval Required  so we will default to the owner*/
			/*        P_resultout:='COMPLETE:N'; */
      			  select user_name into l_user from fnd_user
        			 where user_id = l_owner;
			  l_owner_used := 1;
			end if ;

		if (l_user is null) then
			if(Approver.person_id is null) then
      			  select user_name into l_user from fnd_user
        			 where user_id=Approver.user_id;
   		 	else
	       		  select user_name into l_user from fnd_user
        	             where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
                	end if;
		end if;


		IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('AME approver ' || l_user);
	        END IF;

                 l_itemtype:='GMDQSTST';
                 l_itemkey:=l_event_key||'-'||to_char(sysdate,'dd/mm/yy hh:mi:ss');

                 l_workflow_process:='GMDQSTST_SUB_PROCESS';

                 WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
	                                     itemkey => l_itemkey,
        	                             process =>    l_workflow_process );

	         /* Set the User Attribute */

        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
         					  aname => 'CURRENT_APPROVER',
         					  avalue => l_user);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'APPS_FORM',
         					  avalue =>l_form );
       		/* Set All other Attributes */
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => p_itemkey,
        	 					  aname => 'EVENT_NAME',
         						  avalue =>l_event_name );
        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'EVENT_KEY',
         						  avalue =>l_event_key );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ORG',
         						  avalue =>l_organization ); --INVCONV
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_NO',
         						  avalue =>l_item_no );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_DESC',
         						  avalue =>l_item_desc );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_REVISION',
         						  avalue =>l_item_revision );  --INVCONV
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY',
         						  avalue =>l_study );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY_DESC',
         						  avalue =>l_study_desc );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STATUS',
         						  avalue =>l_status );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLE_QTY',
         						  avalue =>l_sample_qty );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLE_NO',
         						  avalue =>l_sample_no );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY_DATE',
         						  avalue =>l_study_date);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'RESOURCE',
         						  avalue =>l_resource);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SUBINVENTORY',
         						  avalue =>l_storage_subinventory);  --INVCONV
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'LOCATOR',
         						  avalue =>l_storage_locator);      --INVCONV
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'VARIANT_NO',
         						  avalue =>l_variant_no);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STORAGE_SPEC',
         						  avalue =>l_storage_spec);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STGE_SPEC_VER',
         						  avalue =>l_storage_spec_vers);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TIME_NAME',
         						  avalue =>l_time_name);
		    WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
         					  aname => '#FROM_ROLE',
         					  avalue =>l_from_role );

        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'AME_TRANS',
         					  avalue =>l_transaction_type);

                    wf_log_pkg.string(6, 'Dummy','Setting Parent');


                    WF_ENGINE.SETITEMPARENT(itemtype =>l_itemtype,itemkey =>l_itemkey,
                                         parent_itemtype => p_itemtype,
                                         parent_itemkey=> p_itemkey,
                                         parent_context=> NULL);

                   /* start the Workflow process */
                    wf_log_pkg.string(6, 'Dummy','Starting Process');

  		    IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Finished Workflow atributes');
	            END IF;


       /* As this a pure FYI notification we will set the approver to approve status */
          Approver.approval_status := ame_util.approvedStatus;
	 if (l_owner_used = 0) then
          ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);
	 end if;

           WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);

	 close C1;

    END IF;

     p_resultout:='COMPLETE:';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_SS_TIMEPOINT_WF_PKG','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
      raise;

  END VERIFY_EVENT;



PROCEDURE CHECK_NEXT_APPROVER(
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

	/*Update the wf_sent column to show that a notification has been sent */
	update gmd_ss_time_points
        set wf_sent = 'Y'
	where time_point_id = l_event_key;

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
      WF_CORE.CONTEXT ('GMD_SS_TIMEPOINT_WF_PKG','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;


/* Procedure to cancel a workflow for a timepoint and reset the
wf_sent column */
PROCEDURE CANCEL_TIMEPOINT_WF(
      p_timepoint      IN NUMBER,
      p_result         OUT NOCOPY VARCHAR2)
IS

      l_itemtype VARCHAR2(10);
      l_itemkey NUMBER ;

BEGIN

      l_itemtype :='GMDQSTST';
      l_itemkey := p_timepoint ;

      /* Cancel workflow process */
      wf_engine.abortprocess (ITEMTYPE => l_itemtype,
				ITEMKEY => l_itemkey);


      /* update the wf_sent back to N */
	update gmd_ss_time_points
        set wf_sent = 'N'
	where time_point_id = p_timepoint;

      /* Return Success */
       p_result := 'S';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_SS_TIMEPOINT_WF_PKG','CANCEL_TIMEPOINT_WF',l_itemtype,l_itemkey,'Problem Canceling timepoint' );
      p_result := 'E';

      raise;

END CANCEL_TIMEPOINT_WF ;


END GMD_SS_TIMEPOINT_WF_PKG ;


/
