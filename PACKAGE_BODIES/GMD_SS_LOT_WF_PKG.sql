--------------------------------------------------------
--  DDL for Package Body GMD_SS_LOT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_LOT_WF_PKG" AS
/* $Header: GMDQSSLB.pls 120.7 2006/12/05 16:08:36 rlnagara noship $ */


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
 l_transaction_type varchar2(100):='GMDQM_STABILITY_LOT';
 l_user varchar2(32);
 Approver ame_util.approverRecord;


   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;
   l_inventory_item_id NUMBER; --RLNAGARA B4705797
   l_item_no varchar2(240);
   l_item_revision varchar2(3); --Added as part of convergence
   l_item_desc varchar2(240);
   l_item_um varchar2(32);
   l_lot_no varchar2(240);
   l_ss_id  number;       -- BUG#4705797
   l_test_replicate varchar2(240);
   l_orgn_code varchar2(240);
   l_sample_id varchar2(240);
   l_sample_no varchar2(240);
   l_sample_desc varchar2(240);
   l_sample_type varchar2(240);
   l_resource_desc varchar2(240);
   l_resource_num number ;
   l_study varchar2(240);
   l_study_desc varchar2(240);
   l_batch_no varchar2(240);
   l_recipe_no varchar2(240);
   l_recipe_vers varchar2(240);
   l_storage_whse varchar2(240);
   l_storage_location varchar2(240);
   l_storage_spec varchar2(240);
   l_storage_spec_vers varchar2(240);
   l_resource varchar2(240);
   l_formula varchar2(240);
   l_formula_vers varchar2(240);
   l_package varchar2(240);
   l_sample_qty varchar2(240);
   l_sample_uom varchar2(240);
   l_status varchar2(240);
   l_variant_no varchar2(240);
   l_study_date varchar2(240);
   l_sample_event_id varchar2(240);
   l_owner number;
   l_owner_used number := 0;


   /*=====================================
      BUG#4705797 Added ss_id to cursor.
      BUG#4705867 Added sample_qty and uom
                  to cursor.
      BUG#4912224 Replaced mtl_organizations
                  with mtl_parameters.
     =====================================*/
--RLNAGARA B4705797 Added inventory_item_id to the select list of the CURSOR C1
CURSOR C1 IS
SELECT  DISTINCT a.lot_number ,b.meaning, e.ss_no, f.description,e.inventory_item_id,
	g.concatenated_segments item_no, e.revision item_revision,
        g.description item_desc1,  h.organization_code, e.owner, e.ss_id,
        a.sample_qty, a.sample_quantity_uom
 FROM   gmd_ss_material_sources a,
        gmd_Qc_status b,
        gmd_stability_studies_b e ,
        gmd_stability_studies_tl f ,
        mtl_system_items_kfv g,
        mtl_parameters h
 WHERE  a.source_id = l_event_key
   AND a.ss_id = e.ss_id
   AND e.ss_id = f.ss_id
  AND b.entity_type = 'STABILITY'
  AND b.status_code = e.status
  AND g.inventory_item_id = e.inventory_item_id
  AND g.organization_id = e.organization_id
  AND h.organization_id = e.organization_id
  AND f.language = userenv('LANG');

  CURSOR get_from_role IS
     SELECT nvl( text, '')
	FROM wf_Resources where name = 'WF_ADMIN_ROLE'     --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
        AND language = userenv('LANG');

--JD 10/20/2005 added language to role.

  l_from_role varchar2(240);

 BEGIN


    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('StabStudyLot');
       gmd_debug.put_line('Event Name ' || l_event_name );
       gmd_debug.put_line('Event Key ' || l_event_key );

    END IF;

	open get_from_role ;
	fetch get_from_role into l_from_role ;
	close get_from_role ;


    IF P_FUNCMODE='RUN' THEN
     /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

      /* Check which event has been raised */
      wf_log_pkg.string(6, 'Dummy','Entered Stability Study Timepoint Testing '||l_event_key);


          OPEN C1;
            	Fetch C1 into l_lot_no, l_status, l_study,l_study_desc, l_inventory_item_id, l_item_no, l_item_revision,
			l_item_desc ,l_orgn_code, l_owner, l_ss_id, l_sample_qty, l_sample_uom ;
		   /*=====================================
		      BUG#4705797 - added ss_id to cursor
		      and changed parm to be ss_id.
		      BUG#4705867 - added sample_qty and
		      uom to cursor.
		     =====================================*/

			/* Set Form Attribute to the sampling event */

	            --RLNAGARA B4705797 Corrected the Form to be opened.
		    --l_form := 'GMDQSSVT_F:SS_ID="'||l_ss_id||'"';
	            l_form := 'GMDQSMPL_EDIT_F:INVENTORY_ITEM_ID="'||l_inventory_item_id||'" LOT_NUMBER="'
		                ||l_lot_no||'" REVISION="'||l_item_revision||'" SAMPLE_TYPE="I" SOURCE="I"';


			IF (l_debug = 'Y') THEN
			       gmd_debug.put_line('Checking on approvers ');
			END IF;

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
			       gmd_debug.put_line('Approver ' || l_user);
			END IF;


			     l_itemtype:='GMDQSLOT';
			     l_itemkey:=l_event_key||'-'||to_char(sysdate,'dd/mm/yy hh:mi:ss');

			     l_workflow_process:='GMDQSLOT_SUB_PROCESS';

			     IF (l_debug = 'Y') THEN
			       gmd_debug.put_line('Going to set workflow attributes ');
			     END IF;

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
								  avalue =>l_orgn_code );
			    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'ITEM_NO',
								  avalue =>l_item_no );
			    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'ITEM_REVISION',
								  avalue =>l_item_revision );
	-- JD 10/20/2005 Changed item_desc to l_item_revision above.

			    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'ITEM_DESC',
								  avalue =>l_item_desc );
			    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'LOT_NO',
								  avalue =>l_lot_no );
			    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SAMPLE_QTY',
         						  avalue =>l_sample_qty );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLE_UOM',
         						  avalue =>l_sample_uom );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY',
         						  avalue =>l_study );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STUDY_DESC',
         						  avalue =>l_study_desc );
                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'STATUS',
         						  avalue =>l_status );
		    WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
         					  aname => '#FROM_ROLE',
         					  avalue =>l_from_role );

                    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'MSG_DOCUMENT',
         						  avalue =>
 'plsqlclob:GMD_SS_LOT_WF_PKG.Get_WF_Notif/'||l_event_key );


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
		       gmd_debug.put_line('Completed workflow attributes ');
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

	   IF (l_debug = 'Y') THEN
		gmd_debug.put_line('Created workflow process ');
 	   END IF;


	 close C1;


    END IF;


     p_resultout:='COMPLETE:';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_SS_LOT_WF_PKG','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
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
      WF_CORE.CONTEXT ('GMD_SS_LOT_WF_PKG','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;


PROCEDURE Get_WF_Notif(document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	nocopy clob,
                                 document_type	in out	nocopy varchar2) IS


   l_document_id gmd_ss_material_sources.source_id%TYPE;
   l_source number := to_number(document_id);
   l_document VARCHAR2(32000) := '';
   NL  VARCHAR2(1) := fnd_global.newline;

   l_resource_desc varchar2(240);
   l_resource_num number ;
   l_study varchar2(240);
   l_study_desc varchar2(240);
   l_batch_no varchar2(240);
   l_recipe_no varchar2(240);
   l_recipe_vers varchar2(240);
   l_storage_subinventory varchar2(10);
   l_storage_locator varchar2(204);
   l_storage_spec varchar2(240);
   l_storage_spec_vers varchar2(240);
   l_resource varchar2(240);
   l_formula varchar2(240);
   l_formula_vers varchar2(240);
   l_package varchar2(240);
   l_sample_qty varchar2(240);
   l_sample_uom varchar2(240);
   l_date varchar2(240);


 /* This cursor  Will Pick up all material sources for a Given Sample */
 --Cursor C1 is modified for Convergence
 Cursor C1 is
select  distinct b.batch_no,a.recipe_no, c.recipe_version,
   h.sample_qty, h.sample_quantity_uom , h.storage_subinventory, k.concatenated_segments storage_locator,
   h.resources, i.spec_name, i.spec_vers, h.scheduled_start_date
 , j.formula_no, j.formula_vers , d.package_name
 from   gmd_ss_material_sources a,
        gme_batch_header b,
        gmd_recipes c,
        gmd_ss_storage_package d,
        gmd_stability_studies_b e ,
        gmd_stability_studies_tl f ,
        gmd_ss_variants h,
        gmd_specifications i,
        fm_form_mst j,
        mtl_item_locations_kfv k
 where  a.source_id = l_source
     and a.recipe_id = c.recipe_id(+)
     and a.batch_id = b.batch_id(+)
     and a.ss_id = e.ss_id
     and h.material_source_id = a.source_id
     and h.storage_spec_id = i.spec_id
     and h.package_id = d.package_id(+)
     and d.formula_id = j.formula_id(+)
     and h.storage_locator_id = k.inventory_location_id(+) ;


BEGIN
	  /* Add a new line  */
          WF_NOTIFICATION.WriteToClob(document,NL );

          OPEN C1;
            LOOP

             	wf_log_pkg.string(6, 'Dummy','Before Fetching the values. Inside the Loop');

		/*Fetching values from the cursor*/
        	Fetch C1 into l_batch_no, l_recipe_no, l_recipe_vers, l_sample_qty,
			l_sample_uom, l_storage_subinventory, l_storage_locator, l_resource,
			l_storage_spec, l_storage_spec_vers, l_date,
			l_formula, l_formula_vers, l_package ;
             	EXIT when c1%notfound;

		/*Use an FND message and populate it */
		FND_MESSAGE.SET_NAME('GMD','GMD_SS_LOT_BODY');
	        FND_MESSAGE.SET_TOKEN('BATCH', L_BATCH_NO);
	        FND_MESSAGE.SET_TOKEN('RECIPE', l_Recipe_no);
	        FND_MESSAGE.SET_TOKEN('RCP_VERSION', l_recipe_vers);
	        FND_MESSAGE.SET_TOKEN('STORAGE_SPEC', l_storage_spec);
	        FND_MESSAGE.SET_TOKEN('STOR_SPEC_VERSION', l_storage_spec_vers);
	        FND_MESSAGE.SET_TOKEN('RESOURCE',l_resource);
	        FND_MESSAGE.SET_TOKEN('STORAGE_SUBINVENTORY',l_storage_subinventory);
	        FND_MESSAGE.SET_TOKEN('STORAGE_LOCATOR',l_storage_locator);
	        FND_MESSAGE.SET_TOKEN('PACKAGE',l_package);
	        FND_MESSAGE.SET_TOKEN('FORMULA',l_formula);
	        FND_MESSAGE.SET_TOKEN('FORM_VER',l_formula_vers);
	        FND_MESSAGE.SET_TOKEN('SAMPLE_QTY',l_sample_qty);
	        FND_MESSAGE.SET_TOKEN('SAMPLE_UOM',l_sample_uom);
	        FND_MESSAGE.SET_TOKEN('STORAGE_DATE',l_date);


               WF_NOTIFICATION.WriteToClob(document, FND_MESSAGE.GET() );
               WF_NOTIFICATION.WriteToClob(document, NL );
               WF_NOTIFICATION.WriteToClob(document, NL );


      END LOOP;
      CLOSE C1;

END;

END GMD_SS_LOT_WF_PKG ;

/
