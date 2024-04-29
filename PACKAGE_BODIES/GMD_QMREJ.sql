--------------------------------------------------------
--  DDL for Package Body GMD_QMREJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QMREJ" AS
/* $Header: GMDQMRJB.pls 120.2.12000000.3 2007/02/07 12:06:02 rlnagara ship $ */


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
 l_transaction_type varchar2(100):='GMDQMRJ';
 l_user varchar2(32);
 Approver ame_util.approverRecord;


   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;


   l_orgn_code varchar2(240);
   l_sample_type varchar2(10);
   l_sample_type_desc varchar2(240);
   l_sample_source varchar2(240);
   l_source varchar2(10);

   l_ss_id number ;
   l_study_no varchar2(240);
   l_study_desc varchar2(240);

   l_item_no varchar2(240);
   l_item_desc varchar2(240);
   l_revision varchar2(10);

   l_resource varchar2(240);
   l_resource_desc varchar2(240);
   l_instance_num number ;

   l_subinventory varchar2(240);
   l_locator varchar2(240);

 /*Cursor to get the common fields in the workflow notification*/
 CURSOR common_fields IS
   select mp.organization_code, gse.sample_type, glk.meaning
   from gmd_sampling_events gse, mtl_parameters mp, gem_lookups glk
   where gse.sampling_event_id = l_event_key
   and gse.organization_id = mp.organization_id
   and glk.lookup_type = 'GMD_QC_SPEC_TYPE'
   and gse.sample_type = glk.lookup_code;

 CURSOR common_fields1 IS
   select glk.meaning
   from gmd_sampling_events gse, gem_lookups glk
   where gse.sampling_event_id = l_event_key
   and glk.lookup_type = 'GMD_QC_SOURCE'
   and gse.source = glk.lookup_code;

 CURSOR common_fields2 IS
   select glk.meaning
   from gmd_sampling_events gse, gem_lookups glk
   where gse.sampling_event_id = l_event_key
   and glk.lookup_type = 'GMD_QC_MONITOR_RULE_TYPE'
   and gse.source = glk.lookup_code;


 /* This cursor  Will Pick up all details for a Resource Sample */
 Cursor C1 is
   SELECT gse.resources, cr.resource_desc, ri.instance_number
   from cr_rsrc_mst cr,
        gmp_resource_instances ri,
        cr_rsrc_dtl cd,
        gmd_sampling_events gse
   WHERE gse.sampling_event_id = l_event_key
   and cr.resources = gse.resources
   and cd.resources = cr.resources
   and cd.organization_id = gse.organization_id
   and ri.resource_id = cd.resource_id
   and ri.instance_id = gse.instance_id;

 /* This cursor  Will Pick up all sample details for a Stability Study Sample */
 Cursor C2 (ss_id_in number) is
   select a.ss_no, a.description, b.concatenated_segments, b.description, a.revision
   from gmd_stability_studies a,
        mtl_system_items_b_kfv b
   where a.ss_id = ss_id_in
   and b.inventory_item_id = a.inventory_item_id
   and b.organization_id = a.organization_id;

 Cursor C3 is
   select source , c.ss_id
   from gmd_sampling_events a,
        gmd_ss_variants b,
        gmd_stability_studies_b c,
        gmd_ss_time_points d
   where d.sampling_event_id = l_event_key
   and d.variant_id = b.variant_id
   and b.ss_id = c.ss_id
   and a.sampling_event_id = d.sampling_event_id ;

 /* This cursor  Will Pick up all details for a Physical Location Sample */
 cursor C4 is
   select gse.subinventory, mil.concatenated_segments
   from gmd_sampling_events gse, mtl_item_locations_kfv mil
   WHERE sampling_event_id = l_event_key
   and mil.inventory_location_id = gse.locator_id
   and mil.organization_id = gse.organization_id;

 Cursor C5 is
   select source
   from gmd_Sampling_Events
   where sampling_event_id = l_event_key ;

 cursor get_from_role is
   select nvl( text, '')
   from wf_Resources
   where name = 'WF_ADMIN_ROLE' ;

  l_from_role varchar2(240);


 BEGIN


    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Samplerej');
    END IF;

	  open get_from_role ;
	  fetch get_from_role into l_from_role ;
	  close get_from_role ;


    IF P_FUNCMODE='RUN' THEN
     /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

      /* Check which event has been raised */
      wf_log_pkg.string(6, 'Dummy','Entered Sample Rejection Transaction with event_key '||l_event_key);

    /* Get the common fields values*/
     OPEN common_fields;
     FETCH common_fields INTO l_orgn_code, l_sample_type, l_sample_type_desc;
     CLOSE common_fields;

     IF l_sample_type = 'I' THEN
       OPEN common_fields1;
       FETCH common_fields1 INTO l_sample_source;
       CLOSE common_fields1;
     ELSIF l_sample_type = 'M' THEN
       OPEN common_fields2;
       FETCH common_fields2 INTO l_sample_source;
       CLOSE common_fields2;
     END IF;

     IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Organization Code ' || l_orgn_code);
  	     gmd_debug.put_line('Sample Type  ' || l_sample_type);
  	     gmd_debug.put_line('Sample Source' || l_sample_source);
     END IF;

      /* check to see if Stability or Resource/Location Sample */
     open C3;
	   fetch C3 into l_source, l_ss_id ;
     close C3 ;

     IF (l_debug = 'Y') THEN
  	     gmd_debug.put_line('Sample source type  ' || l_source);
  	     gmd_debug.put_line('Stability Study ID  ' || l_ss_id);
     END IF;

     if (l_source = 'T')  then
	      /* This is a stabiliy study sample */
	      open C2 (l_ss_id);
        fetch C2 into l_study_no,l_study_desc,l_item_no,l_item_desc,l_revision;
	      close C2;
     else
        /*This is either Location or Resource Sample */
	      open C5;
		    fetch C5 into l_source ;
	      close C5 ;
	      if (l_source = 'L')  then
		       /* This is a location sample */
		       open C4;
			     fetch C4 into l_subinventory, l_locator;
		       close C4;
	      else
		       /* This is a resource sample */
	         OPEN C1;
        	 Fetch C1 into l_resource, l_resource_desc, l_instance_num;
	         CLOSE C1;
	      end if;
	   end if;

     IF (l_debug = 'Y') THEN
	       gmd_debug.put_line('Checking approvers ');
     END IF;

             	/* Set Form Attribute to the sampling event */
             	l_form := 'GMDQSAMPLES_F:SAMPLING_EVENT_ID="'||l_event_key||'"';

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
       			 null ;
     		else /* No approvers */

      		if(Approver.person_id is null) then
      			  select user_name into l_user from fnd_user where user_id=Approver.user_id;
 		      else
	       		  select user_name into l_user from fnd_user where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
          end if;

  	      IF (l_debug = 'Y') THEN
		          gmd_debug.put_line('Found approvers ');
	        END IF;

          l_itemtype:='GMDQMREJ';
          l_itemkey:=l_event_key||'-'||to_char(sysdate,'dd/mm/yy hh:mi:ss');
          l_workflow_process:='GMDQMREJ_SUB_PROCESS';

          WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                                   itemkey => l_itemkey,
     	                             process =>    l_workflow_process );

	         /* Set the User Attribute */
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
                                                             aname => '#FROM_ROLE',
                                                            avalue => l_user );

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'CURRENT_APPROVER',
     	                                                       avalue => l_user);

          WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
                                                              aname => 'APPS_FORM',
                                                             avalue =>l_form );

       		/* Set All other Attributes */
          WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => p_itemkey,
                                                              aname => 'EVENT_NAME',
                                                             avalue =>l_event_name );

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'EVENT_KEY',
     	                                                        avalue =>l_event_key );

          /* Set Attributes for Common Fields */
          WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
                                                              aname => 'ORG',
                                                             avalue => l_orgn_code);

          WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
                                                              aname => 'SMPLGRP_TYPE',
                                                             avalue => l_sample_type_desc);

          WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
                                                              aname => 'SMPLGRP_SOURCE',
                                                             avalue => l_sample_source);

          /* Set Attributes for Stability Study Sample Group */
          WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
                                                              aname => 'STUDY',
                                                             avalue => l_study_no);

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'STUDY_DESC',
     	                                                       avalue => l_study_desc);

    	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
    	                                                        aname => 'ITEM_NO',
    	                                                       avalue => l_item_no);

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'ITEM_DESC',
     	                                                       avalue =>l_item_desc);

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'REVISION',
     	                                                       avalue =>l_revision);

          /* Set Attributes for Resource Sample Group */
        	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
        	                                                    aname => 'RESOURCE',
        	                                                   avalue => l_resource);

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'RESOURCE_DESC',
     	                                                       avalue => l_resource_desc);

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'RESOURCE_INST',
     	                                                       avalue => l_instance_num);

          /* Set Attributes for Resource Sample Group */
     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'SUBINVENTORY',
     	                                                       avalue => l_subinventory);

        	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
        	                                                    aname => 'LOCATOR',
        	                                                   avalue =>  l_locator);

     	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
     	                                                        aname => 'AME_TRANS',
     	                                                       avalue =>l_transaction_type);

          wf_log_pkg.string(6, 'Dummy','Setting Parent');

          WF_ENGINE.SETITEMPARENT(itemtype =>l_itemtype,itemkey =>l_itemkey,
                                  parent_itemtype => p_itemtype,
                                         parent_itemkey=> p_itemkey,
                                         parent_context=> NULL);

          /* start the Workflow process */
          wf_log_pkg.string(6, 'Dummy','Starting Process');

         /* As this a pure FYI notification we will set the approver to approve status */
          Approver.approval_status := ame_util.approvedStatus;
          ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);


          WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);

	        IF (l_debug = 'Y') THEN
		         gmd_debug.put_line('created workflow process ');
	        END IF;


	     end if; /* No approver condition */

    END IF;  -- P_FUNCMODE='RUN'


     p_resultout:='COMPLETE:';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMREJ','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
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
      WF_CORE.CONTEXT ('GMD_QMREJ','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;


END GMD_QMREJ;

/
