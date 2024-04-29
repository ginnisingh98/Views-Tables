--------------------------------------------------------
--  DDL for Package Body GMD_SS_BATCH_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_BATCH_WF_PKG" AS
/* $Header: GMDQSSBB.pls 120.4 2006/12/05 16:07:30 rlnagara noship $ */

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
 l_transaction_type varchar2(100):='GMDQM_STABILITY_BATCH';
 l_user varchar2(32);
 Approver ame_util.approverRecord;


   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;
   l_orgn_code varchar2(3); --Added as part of Convergence changes
   l_item_no varchar2(240);
   l_item_desc varchar2(240);
   l_revision varchar2(3);  --Added as part of Convergence changes
   l_item_um varchar2(32);
   l_study varchar2(240);
   l_study_desc varchar2(240);
   l_recipe_no varchar2(240);
   l_recipe_vers varchar2(240);
   l_sample_qty varchar2(240);
   l_sample_uom varchar2(240);
   l_status varchar2(240);
   l_Sched_date varchar2(240);
   l_plant varchar2(240);
   l_owner number;
   l_owner_used number := 0;


--Cursor C1 is modified for Convergence
Cursor C1 is
select  distinct b.meaning, e.ss_no, f.description, h.organization_code,
        e.scheduled_start_date, g.concatenated_segments item_no,
        g.description item_desc1, e.revision, i.organization_code plant_code,
        a.sample_qty, a.sample_quantity_uom,
        c.recipe_no, c.recipe_version, e.owner,e.ss_id -- Bug#3374906
 from   gmd_ss_material_sources a,
        gmd_Qc_status b,
        gmd_recipes c,
        gmd_stability_studies_b e ,
        gmd_stability_studies_tl f ,
        mtl_system_items_kfv g,
        mtl_parameters h,
        mtl_parameters i
 where  a.source_id = l_event_key
       and a.ss_id = e.ss_id
       and e.ss_id = f.ss_id
       and c.recipe_id(+) = a.recipe_id
       and e.inventory_item_id = g.inventory_item_id
       and e.organization_id = g.organization_id
       and b.entity_type = 'STABILITY'
       and b.status_code = e.status
       and h.organization_id = e.organization_id
       and i.organization_id = a.source_organization_id
       and f.language = userenv('LANG') ;

  cursor get_from_role is
     select nvl( text, '')
	from wf_Resources
              where name = 'WF_ADMIN_ROLE'   --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
              and language = userenv('LANG'); --Bug# 4594306. Added this condition.

  l_from_role varchar2(240);
  l_study_id  NUMBER := 0; --Bug#3374906

 BEGIN

     IF (l_debug = 'Y') THEN
 	      gmd_debug.log_initialize('StabStudyBatch');
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
             	Fetch C1 into l_status, l_study, l_study_desc, l_orgn_code, l_sched_date,
			l_item_no, l_item_desc , l_revision, l_plant, l_sample_qty, l_sample_uom,
			l_recipe_no, l_recipe_vers, l_owner,
			l_study_id; --Bug#3374906

             	/* Set Form Attribute to the sampling event */
             	--BUG#3374906 A.Sriram Modified the parameter name from SOURCE_ID to SS_ID
             	--and l_event_key to l_study_id in the following statement.
             	l_form := 'GMDQSSVT_F:SS_ID="'||l_study_id||'"';


              	/* Start the Workflow for the Given Combination */
              	ame_api.clearAllApprovals(applicationIdIn =>   l_application_id,
                                        transactionIdIn =>   l_event_key,
                                        transactionTypeIn => l_transaction_type);

              	wf_log_pkg.string(6, 'Dummy','Approvers Cleared');
              	ame_api.getNextApprover(applicationIdIn => l_application_id,
                                      transactionIdIn => l_event_key,
                                      transactionTypeIn => l_transaction_type,
                                      nextApproverOut => Approver);

      		if(Approver.user_id is null and Approver.person_id is null) then
       			/* No Approval Required */
			/*        P_resultout:='COMPLETE:N';
				return; */
      			  select user_name into l_user from fnd_user
        			 where user_id = l_owner;
			  l_owner_used := 1;
     			end if;


		if (l_user is null) then
	      		if(Approver.person_id is null) then
      				  select user_name into l_user from fnd_user
        				 where user_id=Approver.user_id;
     		 	else
	       		  select user_name into l_user from fnd_user
        	             where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
                	end if;
		end if ;

		    IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Approver  ' || l_user);
		    END IF;

                     l_itemtype:='GMDQSBAT';
                     l_itemkey:=l_event_key||'-'||to_char(sysdate,'dd/mm/yy hh:mi:ss');

                     l_workflow_process:='GMDQSBAT_SUB_PROCESS';

                     WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
	                                     itemkey => l_itemkey,
        	                             process =>    l_workflow_process );


		    IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Going to set workflow attributes ');
		    END IF;

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
         						  aname => 'ITEM_NO',
         						  avalue =>l_item_no );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_DESC',
         						  avalue =>l_item_desc );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_REVISION',
         						  avalue =>l_revision );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY',
         						  avalue =>l_study );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY_DESC',
         						  avalue =>l_study_desc );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ORG',
         						  avalue =>l_orgn_code );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STATUS',
         						  avalue =>l_status );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'PLANT',
         						  avalue =>l_plant );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'RECIPE',
         						  avalue =>l_recipe_no);
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'RECIPE_VERSION',
         						  avalue =>l_recipe_vers );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLE_QTY',
         						  avalue =>l_sample_qty );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLE_UOM',
         						  avalue =>l_sample_uom );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY_DATE',
         						  avalue =>l_sched_date);
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
		       gmd_debug.put_line('Finished setting workflow attributes ');
		    END IF;

	       /* As this a pure FYI notification we will set the approver to approve status */
	          Approver.approval_status := ame_util.approvedStatus;

		 if (l_owner_used = 0) then
	        	  ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);
		 end if ;

        	 WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);

	 close C1;


    END IF;


     p_resultout:='COMPLETE:';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_SS_BATCH_WF_PKG','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
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
      WF_CORE.CONTEXT ('GMD_SS_BATCH_WF_PKG','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;


END GMD_SS_BATCH_WF_PKG ;

/
