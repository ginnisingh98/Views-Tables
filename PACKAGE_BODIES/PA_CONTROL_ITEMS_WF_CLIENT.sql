--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_ITEMS_WF_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_ITEMS_WF_CLIENT" as
/* $Header: PACIWFCB.pls 120.4.12010000.2 2008/10/15 11:38:16 rthumma ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PACIWFCB.pls
 DESCRIPTION :
  This file provided client extension procedures that are called
  to execute each activity in the Issue and Change Document Workflow.

 USAGE:    sqlplus apps/apps @PAPRWFCB.pls

 PROCEDURES AND PARAMETERS:

  start_workflow

    p_item_type      : The workflow item type.
    p_process_name   : Name of the workflow process.
    p_item_key       : The workflow item key.
    p_ci_id          : Control Item Identifier.
    x_msg_count      : The number of messages being sent.
    x_msg_data       : The content of the message.
    x_return_status  : The return status of the message.


  set_ci_approver

    p_item_type      : The workflow item type.
    p_item_key       : The workflow item key.
    actid            : Identifier of the action.
    funcmode         : Workflow function mode.
    resultout        : Process result.

  set_notification_party

    p_item_type      : The workflow item type.
    p_item_key       : The workflow item key.
    p_status         : The control item status.
    actid            : Identifier of the action.
    funcmode         : Workflow function mode.
    resultout        : Process result.



 HISTORY     : 07/22/02 SYAO Initial Creation
               08/18/04 mumohan  Bug#3838957: Added the condition to exclude
	                         the end dated users in the cursors
				 get_approver_list and get_notification_list.
	       08/03/05 raluthra Bug 4527617. Replaced the usage of fnd_user.
	                         customer_id with fnd_user.person_party_id
				 for R12 ATG Mandate.
	       08/05/05 raluthra Bug 4358517: Changed the definition of
	                         l_org local variable from VARCHAR2(60) to
				 pa_project_lists_v.carrying_out_organization_name%TYPE
               10/15/08 rthumma  Bug 6843085: Added changes in set_ci_approver to set the
                                 control item status to previous status when there is no project manager.
=============================================================================*/

/*======================Beginning of template code=========================+

 The following templates demonstrate how you can use the client extension
 to customize the behavior of the Issue and Change Document Workflow.
 Three examples are included:
    1.   Start_Workflow: You can set additional Workflow Item Attributes

    2.   Set_Ci_Approver: You can override the logic to set your own
         approver for the Approvel Process

    3.   Set_notification_party: You can override the logic to set your
         own notification party in case the control item is approved or
         rejected.

  Procedure  start_workflow
  (
  p_item_type         IN     VARCHAR2
  , p_process_name      IN     VARCHAR2
  , p_item_key          IN     NUMBER
  , p_ci_id        IN     NUMBER
  , x_msg_count      out     NUMBER
  , x_msg_data       OUT    VARCHAR2
  , x_return_status    OUT    VARCHAR2
  ) is

  -- The Purpose of Procedure is to save the workflow item attributes needed
  -- for the workflow processes.

  -- define the cursors you will need to retrieve information

  -- define local variables you will need
  begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- set item attributes for the workflow process.
  -- an example of setting of various item attributes are shown below
  -- please note that certain item attributes must be set in order for the
  -- workflow approval process to work properly. For example, item_type,
  -- item_key, etc. The best way to override this procedure is to copy the
  -- code from start_workflow procedure and add your logic to the very end.


  wf_engine.SetItemAttrText( p_item_type
  , p_item_key
  , 'ITEM_TYPE'
  , p_item_type
  );

  wf_engine.SetItemAttrText( p_item_type
  , p_item_key
  , 'ITEM_KEY'
  , p_item_key
  );

  wf_engine.SetItemAttrText(itemtype => p_item_type,
  itemkey  => p_item_key,
  aname    => 'HISTORY',
  avalue   =>
  'PLSQL:PA_WORKFLOW_HISTORY.show_
  history/'||
  p_item_type||':'||
  p_item_key );

  -- Add your own setting here. Please be aware that the item attributes you
  -- are setting must exist in the workflow file. So customize the workflow to
  -- create new item attribute, then add your code here to set them when
  -- the workflow process is launched.

  EXCEPTION

  WHEN OTHERS THEN

  x_msg_count := 1;
  x_msg_data := substr(SQLERRM,1,2000);
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  end start_workflow;


  PROCEDURE set_ci_approver(
  p_item_type                      IN      VARCHAR2
  ,p_item_key                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     VARCHAR2 )
  IS

  -- The Purpose of Procedure is to set the approver for the control item
  -- approval process.
  -- The way to set to approver is to set the workflow item attribute
  -- 'CI_APPROVER' and 'CI_APPROVER_NAME'. The approval process will pick
  -- up these values when it tries to decide to whom it should send out
  -- the notification.
  -- 'CI_APPROVER' is a workflow adhoc user role, which is created within
  -- this procedure.
  -- 'CI_APPROVER_NAME' is a place holder to store the name of the approver




  -- define the cursors you will need to retrieve information

  -- define local variables you will need

  begin

  -- retrieve the item attributes from workflow process, such as Control Item
  -- ID, Submitted By ID, and Project Manager ID, etc. These attributes can
  -- be used to determine the approver of the Control Item

  -- create a adhoc role so that we can use this role for notification
  -- you can keep the logic of creating role in this procedure untouched.

  -- run the cursor the retrieve your approver, your approver needs to have
  -- user_name , person_name or email_address.
  -- this is part which you can override to insert your own logic

  -- create a adhoc user if the user does not exists in the system already.

  -- add user name to a user list. This user list can not have duplicate.
  -- so remove any duplicate if necessary.

  -- add user the adhoc role by calling  WF_DIRECTORY.AddUsersToAdHocRole
  -- you can look at the original code in the procedure for example.

  -- set the item attribute CI_APPROVER and CI_APPROVER_NAME

  -- set return result to wf_engine.eng_completed||':'||'T';

  EXCEPTION

	   WHEN OTHERS THEN
	      RAISE;


  end set_ci_approver;


  PROCEDURE set_notification_party(
  p_item_type   IN      VARCHAR2
  ,p_item_key   IN      VARCHAR2
  ,p_status IN VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     VARCHAR2
  ) IS

  -- The Purpose of Procedure is to set the notification party for the
  -- approval rejected or approved notification message.
  --
  -- The way to set to approver is to set the workflow item attribute
  -- 'CI_NOTIFICATION_PARTY'. The notification process will pick
  -- up these values when it tries to decide to whom it should send out
  -- the notification.
  -- 'CI_NOTIFICATION_PARTY' is a workflow adhoc user role, which is created
  -- within this procedure.

  -- define the cursors you will need to retrieve information

  -- define local variables you will need

  begin

  -- retrieve the item attributes from workflow process, such as Control Item
  -- ID, Submitted By ID, and Project Manager ID, etc.  These attributes can
  -- be used to determine the notification party.

  -- create a adhoc role so that we can use this role for notification
  -- you can keep the logic of creating role in this procedure untouched.

  -- run the cursor the retrieve your party, your party needs to have
  -- user_name , person_name or email_address.
  -- this is part which you can override to insert your own logic

  -- create a adhoc user if the user does not exists in the system already.

  -- add user name to a user list. This user list can not have duplicate.
  -- so remove any duplicate if necessary.

  -- add user the adhoc role by calling  WF_DIRECTORY.AddUsersToAdHocRole
  -- you can look at the original code in the procedure for example.

  -- set the item attribute CI_NOTIFICATION_PARTY

  -- set return result to wf_engine.eng_completed||':'||'T';
  end set_notification_party;

=============================================================================*/


  /********************************************************************
  * Procedure     : start_workflow
  * Purpose       :
  *********************************************************************/
  Procedure  start_workflow
  (
   p_item_type         IN     VARCHAR2
   , p_process_name      IN     VARCHAR2
   , p_item_key          IN     NUMBER

   , p_ci_id        IN     NUMBER

   , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
   , x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
        IS
	   l_project_mgr_id NUMBER;

	   l_submitted_by_id NUMBER;

	   l_url     VARCHAR2(2000);

	    CURSOR get_project_mgr_party_id
	       IS
		  select hp.party_id
		    from pa_project_parties ppp,
		    pa_control_items pci,
		    hz_parties hp
		    where pci.ci_id = p_ci_id
		    and ppp.project_role_id = 1
		    and ppp.project_id = pci.project_id
		    and trunc(sysdate) between ppp.start_date_active and nvl(ppp.end_date_active, sysdate)
		    AND ((ppp.resource_type_id = 101 and hp.orig_system_reference = 'PER:' || ppp.resource_source_id
			  ) or (ppp.resource_type_id = 112 and hp.party_id = ppp.resource_source_id
				));


	    CURSOR get_submitted_by_id
	      IS
		 select party_id from
		   (
		    select hp.party_id
		     from fnd_user fu,
		    hz_parties hp
		    where fu.user_id = fnd_global.user_id
		    and fu.employee_id is null
		    and fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
		    union
		     select hp.party_id
		    from fnd_user fu,
		     hz_parties hp
		    where fu.user_id = fnd_global.user_id
		    and fu.employee_id is not null
		    and 'PER:' || fu.employee_id = hp.orig_system_reference);

	     CURSOR get_ci_info
		      IS
			 SELECT
			   pci.project_id,
			   pci.object_id,
			   pci.object_type,
			   pci.date_required,
		     pct.short_name ci_type_name,
		     pci.ci_number,
		     summary,
		     decode(highlighted_flag, 'N', 'No', 'Yes') highlighted,
		     priority_code,
		     hp.party_name,
		     pcc.class_code classification,
		     pci.record_version_number record_version_number,
		     pl.meaning ci_type_class
		     FROM pa_control_items pci, pa_ci_types_tl pct,
		     pa_ci_types_b pcb, pa_lookups pl, hz_parties hp,
		     pa_class_codes pcc
		     WHERE ci_id = p_ci_id
		     and pci.ci_type_id = pct.ci_type_id
		     and pl.lookup_code = pcb.ci_type_class_code
		     AND pcb.ci_type_id = pct.ci_type_id
		     and pl.lookup_type = 'PA_CI_TYPE_CLASSES'
		     and pci.owner_id = hp.party_id
		     AND pcc.class_code_id = pci.classification_code_id;



	      CURSOR get_project_info(l_project_id number) IS
	       SELECT
		 customer_name,
		 person_name,
		 carrying_out_organization_name
		 FROM pa_project_lists_v
		 WHERE project_id = l_project_id;

	      l_project_name VARCHAR2(30);
	      l_project_number  VARCHAR2(25);

	      l_task_number    VARCHAR2(25);
	      l_task_name   VARCHAR2(30);
	      l_customer  VARCHAR2(4000);
	      l_project_manager  VARCHAR2(240);
	      l_org  pa_project_lists_v.carrying_out_organization_name%TYPE; -- Bug 4358517.

        BEGIN

	   x_return_status := FND_API.G_RET_STS_SUCCESS;

	    wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'ITEM_TYPE'
                                      , p_item_type
				       );

	     wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'ITEM_KEY'
                                      , p_item_key
					 );


	      wf_engine.SetItemAttrText(itemtype => p_item_type,
					itemkey  => p_item_key,
					aname    => 'HISTORY',
					avalue   =>
					'PLSQL:PA_WORKFLOW_HISTORY.show_history/'||
					p_item_type||':'||
					p_item_key );


	      wf_engine.SetItemAttrText(itemtype => p_item_type,
					itemkey  => p_item_key,
					aname    => 'CLOB_CONTENT',
					avalue   =>
					'plsqlclob:pa_control_items_workflow.show_clob_content/'||
					p_ci_id);



	      wf_engine.SetItemAttrNumber( p_item_type
					   , p_item_key
					   , 'CI_ID'
					   , p_ci_id
					   );


	      wf_engine.SetItemAttrNumber( p_item_type
					   , p_item_key
                                      , 'WF_OBJECT_ID'
					   , p_ci_id
					   );

	   OPEN get_project_mgr_party_id;
	   FETCH get_project_mgr_party_id INTO l_project_mgr_id;
	   CLOSE get_project_mgr_party_id;

	    wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'PROJ_MGR_ID'
                                      , l_project_mgr_id
					 );

	    OPEN get_submitted_by_id;
	    FETCH get_submitted_by_id INTO l_submitted_by_id;
	    CLOSE get_submitted_by_id;


	    wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'SUBMITTED_BY_ID'
                                      , l_submitted_by_id
					);

	    FOR rec IN get_ci_info LOOP
	       pa_utils.getprojinfo(rec.project_id, l_project_number, l_project_name);

	        wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'PROJECT_ID'
                                      , rec.project_id
					     );



		 wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'RECORD_VERSION_NUMBER'
                                      , rec.record_version_number
					     );


	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'PROJECT_NAME'
                                      ,l_project_name
					 );

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'PROJECT_NUMBER'
                                      ,l_project_number
					  );

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'PROJECT'
                                      ,l_project_name||'('||l_project_number||')'
					 );

	       wf_engine.SetItemAttrDate( p_item_type
                                      , p_item_key
                                      , 'DATE_REQUIRED'
                                      ,rec.date_required
					  );

	        wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'SUMMARY'
                                      ,rec.summary
					   );

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'CONTROL_ITEM_TYPE'
                                      ,rec.ci_type_name
					  );

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'CONTROL_ITEM_CLASS'
                                      ,rec.ci_type_class
					   );

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'CONTROL_ITEM_NUMBER'
                                      ,rec.ci_number
					  );

	       wf_engine.SetItemAttrText( p_item_type
					  , p_item_key
					  , 'PRIORITY'
					  ,rec.priority_code
					  );

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
					  , 'CI_OWNER'
					  ,rec.party_name
					  );

	       wf_engine.SetItemAttrText( p_item_type
					  , p_item_key
					  , 'CLASSIFICATION'
					  ,rec.classification
					  );

	       -- set project manager, organization name and customer
	      OPEN get_project_info(rec.project_id);

	      FETCH get_project_info INTO l_customer,l_project_manager, l_org;


	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'PROJECT_MANAGER'
                                      ,l_project_manager
					  );


	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'ORGANIZATION'
                                      ,l_org
					  );

	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'CUSTOMER'
                                      ,l_customer
					  );

	      CLOSE get_project_info;

	       IF rec.object_type = 'PA_TASKS' THEN
		  -- set task name, task number
		  pa_utils.gettaskinfo(rec.object_id, l_task_number, l_task_name);
		  wf_engine.SetItemAttrText( p_item_type
					     , p_item_key
					     , 'TASK_NAME'
					     ,l_task_name
					     );

		  wf_engine.SetItemAttrText( p_item_type
					     , p_item_key
					     , 'TASK_NUMBER'
					     ,l_task_number
					 );

	       END IF;


	       l_url := 'JSP:/OA_HTML/OA.jsp?' ||
		 'akRegionCode=PA_CI_CI_REVIEW_LAYOUT&akRegionApplicationId=275&addBreadCrumb=RP&paCiId='||p_ci_id || '&paProjectId=' || rec.project_id;

	       wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'CI_LINK'
                                      , l_url
					  );




	    END LOOP;



        EXCEPTION

	   WHEN OTHERS THEN

	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


        END start_workflow;


	 /********************************************************************
        * Procedure     : set_ci_approver
        * Parameters IN :
        * Parameters OUT: Return Status
        * Purpose       :
        *********************************************************************/
	  PROCEDURE set_ci_approver(
					p_item_type                      IN      VARCHAR2
					,p_item_key                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

	  IS


	     l_approval_role varchar2(30) := NULL;
	     l_role_users    varchar2(30000) := NULL;

	     l_ci_id NUMBER;
	     l_proj_mgr_id NUMBER;
	     l_proj_mgr_name VARCHAR2(200);
	     l_proj_mgr_full_name VARCHAR2(200);
	     l_submitted_by_id NUMBER;
	     l_user_name VARCHAR2(200);

	     -- Bug 6843085
	     x_return_status  VARCHAR2(100);
	     x_msg_count      NUMBER;
	     x_msg_data       VARCHAR2(200);

	     CURSOR get_user_name
	       IS
		  SELECT user_name
		    FROM fnd_user
		    WHERE user_id = FND_GLOBAL.user_id;


	     CURSOR get_approver_list
	       IS
		  select user_name, party_name, email_address
		    from (
			  select fu.user_name, hp.party_name, hp.email_address
			  from fnd_user fu,
			  hz_parties hp
			  where fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
			  and hp.party_id = l_proj_mgr_id
			  and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate)  /* Bug#3838957  */
			  union
			  select fu.user_name, hp.party_name, hp.email_address
			  from fnd_user fu,
			  hz_parties hp,
			  per_all_people_f papf
			  where
			  fu.employee_id = Substr(hp.orig_system_reference, 5, Length(hp.orig_system_reference))
			  AND 'PER:' = Substr(hp.orig_system_reference,1,4) 	--			  'PER:' || fu.employee_id = hp.orig_system_reference
			  and hp.party_id = l_proj_mgr_id
			  and    trunc(sysdate)
			  between papf.EFFECTIVE_START_DATE
			  and		  Nvl(papf.effective_end_date, Sysdate + 1)
			  and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate)  /* Bug#3838957  */
			  and papf.person_id = fu.employee_id)
		    ;

	     -- Bug 6843085
	     CURSOR get_prev_status(p_ci_id IN VARCHAR2) is
	     select a.old_project_status_code, a.new_project_status_code
	     from (select obj_status_change_id,
	                  old_project_status_code,
	                  new_project_status_code
	           from pa_obj_status_changes
	           where object_type = 'PA_CI_TYPES'
	           and object_id = p_ci_id
	           order by obj_status_change_id desc) a
	     where rownum = 1;

	     l_prev_status   pa_obj_status_changes.old_project_status_code%TYPE;
	     l_curr_status   pa_obj_status_changes.new_project_status_code%TYPE;
	     l_comment       pa_ci_comments.comment_text%TYPE;
	     -- Bug  6843085

	               display_name VARCHAR2(2000);
email_address VARCHAR2(2000);
notification_preference VARCHAR2(2000);
language VARCHAR2(2000);
territory VARCHAR2(2000);

	  BEGIN


	      l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'CI_ID');

	      l_submitted_by_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'SUBMITTED_BY_ID');


	      l_proj_mgr_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'PROJ_MGR_ID');



	     l_approval_role := 'APPR_' ||p_item_type ||  p_item_key;


	     IF l_proj_mgr_id IS NOT null THEN

	      for v_approvers in get_approver_list loop

		 l_proj_mgr_name := v_approvers.user_name;
		 l_proj_mgr_full_name:= v_approvers.party_name;


		 if (l_role_users is not null) then
		    l_role_users := l_role_users || ',';
		 end if;

		 -- Create adhoc users
		 wf_directory.getroleinfo(v_approvers.user_name,display_name,
					  email_address,notification_preference,language,territory);
		 if display_name is null THEN


		    WF_DIRECTORY.CreateAdHocUser( name => v_approvers.user_name
						  , display_name => v_approvers.party_name
						  --, notification_preference => 'MAILTEXT'
						  , EMAIL_ADDRESS =>v_approvers.email_address);
		 END IF;
		 l_role_users := l_role_users || v_approvers.user_name;
	      end loop;

	   END IF;



	     WF_DIRECTORY.CreateAdHocRole( role_name         => l_approval_role
					   , role_display_name => l_proj_mgr_full_name
					   , expiration_date   => sysdate+1 -- Set expiration_date for bug#5962401
					   );


	   IF (l_role_users is NOT NULL) THEN

	      WF_DIRECTORY.AddUsersToAdHocRole( l_approval_role
		       				, l_role_users);





	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'CI_APPROVER'
					  , l_approval_role);

	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'CI_APPROVER_NAME'
					  , l_proj_mgr_name);



	      resultout := wf_engine.eng_completed||':'||'T';


	    ELSE

	      resultout := wf_engine.eng_completed||':'||'F';
	      -- Bug 6843085
	      IF l_proj_mgr_id IS null THEN
	      OPEN get_prev_status(l_ci_id);
	      FETCH get_prev_status INTO l_prev_status, l_curr_status;
	      CLOSE get_prev_status;

	      pa_control_items_pvt.UPDATE_CONTROL_ITEM_STATUS (
	                p_api_version           => 1.0
	               ,p_init_msg_list         => FND_API.G_TRUE
	               ,p_validate_only         => FND_API.G_FALSE
	               ,p_ci_id                 => l_ci_id
	               ,p_status_code           => l_prev_status
	               ,p_record_version_number => NULL
	               ,x_return_status         => x_return_status
	               ,x_msg_count             => x_msg_count
	               ,x_msg_data              => x_msg_data);

	      If x_return_status = FND_API.G_RET_STS_SUCCESS then

	      fnd_message.set_name('PA', 'PA_CI_ERR_PM_WF_COMMENT');
	      l_comment := fnd_message.get;
	      DBMS_LOCK.SLEEP(1);
	      PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT( p_object_type => 'PA_CI_TYPES'
	                                                       ,p_object_id   => l_ci_id
	                                                       ,p_type_code   => 'CHANGE_STATUS'
	                                                       ,p_status_type  => 'CONTROL_ITEM'
	                                                       ,p_new_project_status => l_prev_status
	                                                       ,p_old_project_status => l_curr_status
	                                                       ,p_comment            => l_comment
	                                                       ,x_return_status      => x_return_status
	                                                       ,x_msg_count          => x_msg_count
	                                                       ,x_msg_data           => x_msg_data );

	      end if;
	      end if;
	      -- Bug 6843085

	   END IF;



	   commit;


	EXCEPTION

	   WHEN OTHERS THEN
	      RAISE;

	END ;

	/********************************************************************
        * Procedure     : set_notification_party
        * Parameters IN :
        * Parameters OUT: Return Status
        * Purpose       :
        *********************************************************************/
	PROCEDURE set_notification_party(
					p_item_type   IN      VARCHAR2
					,p_item_key   IN      VARCHAR2
					,p_status IN VARCHAR2
					,actid        IN      NUMBER
					,funcmode     IN      VARCHAR2
					,resultout    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
						) IS

	       l_ci_id NUMBER;
	       l_owner_id NUMBER;

	       CURSOR get_notification_list
	       IS
		  select user_name, party_name, email_address
		    from (
			  select fu.user_name, hp.party_name, hp.email_address
			  from fnd_user fu,
			  hz_parties hp
			  where fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
			  and hp.party_id = l_owner_id
			  and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate)  /* Bug#3838957  */
			  union
			  select fu.user_name, hp.party_name, hp.email_address
			  from fnd_user fu,
			  hz_parties hp,
			  per_all_people_f papf
			  where
			  --'PER:' || fu.employee_id = hp.orig_system_reference
			   fu.employee_id = Substr(hp.orig_system_reference, 5, Length(hp.orig_system_reference))
			  AND 'PER:' = Substr(hp.orig_system_reference,1,4)
			  and hp.party_id = l_owner_id
			  and    trunc(sysdate)
			  between papf.EFFECTIVE_START_DATE
			  and		  Nvl(papf.effective_end_date, Sysdate + 1)
			  and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate)  /* Bug#3838957  */
			  and papf.person_id = fu.employee_id)
		    ;
	       CURSOR get_owner_id
		 is
		    SELECT
		      owner_id
		      FROM pa_control_items
		      WHERE ci_id = l_ci_id;

	       l_role varchar2(30) := NULL;
	       l_role_users    varchar2(30000) := NULL;
	       display_name VARCHAR2(2000);
	       email_address VARCHAR2(2000);
	       notification_preference VARCHAR2(2000);
	       language VARCHAR2(2000);
	       territory VARCHAR2(2000);

	BEGIN

	    l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'CI_ID');

	    OPEN get_owner_id;
	    FETCH get_owner_id INTO l_owner_id;
	    CLOSE get_owner_id;

	    l_role := 'NOTFY_' ||p_item_type ||  p_item_key;

	    WF_DIRECTORY.CreateAdHocRole( role_name         => l_role
					  , role_display_name => l_role
					  , expiration_date   => sysdate+1 -- Set expiration_date for bug#5962401
					   );

	    for v_party in get_notification_list loop


		 if (l_role_users is not null) then
		    l_role_users := l_role_users || ',';
		 end if;

		 -- Create adhoc users
		 wf_directory.getroleinfo(v_party.user_name,display_name,
					  email_address,notification_preference,language,territory);
		 if display_name is null THEN

		    WF_DIRECTORY.CreateAdHocUser( name => v_party.user_name
						  , display_name => v_party.party_name
						  --, notification_preference => 'MAILTEXT'
						  , EMAIL_ADDRESS =>v_party.email_address);
		 END IF;
		 l_role_users := l_role_users || v_party.user_name;
	    end loop;

	    IF (l_role_users is NOT NULL) THEN
	      WF_DIRECTORY.AddUsersToAdHocRole( l_role, l_role_users);

	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'CI_NOTIFICATION_PARTY'
					  , l_role);
	      resultout := wf_engine.eng_completed||':'||'T';
	     ELSE

	      resultout := wf_engine.eng_completed||':'||'F';

	    END IF;




	END;


END pa_control_items_wf_client;


/
