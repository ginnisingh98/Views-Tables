--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_ITEMS_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_ITEMS_WORKFLOW" as
/* $Header: PACIWFPB.pls 120.11.12010000.4 2009/12/01 07:23:36 anuragar ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PACIWFPB.pls
 DESCRIPTION :
               This file creates package procedures that are called to
               execute each activity in the Control Item Workflow.



 HISTORY     : 08/19/02 SYAO Initial Creation
               20/01/04 sanantha  Bug 3297238. FP M changes.
               30/01/04 sukhanna  Bug 3297238 FP M changes. Currently the notification list is processed for only one party id. After this
                                   change, it will process the notification list for each of the party id.
               31/01/04 sukhanna  Bug 3297238 FP M changes. After this change the
			                      notification list will be processed for each of the party id.
               27/01/04 mumohan   Bug# 3297238 FP M changes
               04/02/04 sukhanna  Bug 3297238 FP M changes.
               31/05/04 sukhanna  Removing the covering select clause in the
                                  cursor definiton of get_notification_list & get_name
	       23/06/04 rasinha   Bug# 3691192 FP M Changes
	                          Added three procedures namely CLOSE_CI_ACTION,KEEP_OPEN and CANCEL_NOTIF_AND_ABORT_WF.
				  CLOSE_CI_ACTION and KEEP_OPEN are called from the PAWFCIAC workflow funtions.
				  CLOSE_CI_ACTION closes an Action without signing it off,
				  KEEP_OPEN keeps the action open and registers any comment given by the user and
				  CANCEL_NOTIF_AND_ABORT_WF cancels any open notification for an action and also aborts the workflow.
				  Also added some item attributes in the workflow PAWFCIAC.
	       30-07-04 rasinha   Modified the file for Bug# 3802238.Captured the Sign-off flag value from workflow Notification
	                          and updated the ci action in CI_CLOSE_ACTION_PROCEDURE.
               18-08-04 mumohan   Bug#3838957: Added the condition to exclude the end dated users in the cursor
	                          get_notification_list, is_user_valid and get_name.
	       27/08/04 sanantha  Bug 3787169. call the api modify_wf_clob_content
				  before passing the clob to workflow
               24-09-04 rasinha   Bug 3877985. Modified the file update the who columns in the procedure
	                          CLOSE_CI_ACTION and KEEP_OPEN with action assignee and not by fnd_global.user_id.
               01-12-04 sukhanna  Bug 3974641. Replacing PA_CI_CI_REVIEW_LAYOUT AK region name with the xml file name CiCiReviewPG.
	       10-Dec-04 rasinha  Bug 4049901. Modified the procedure to set the role_display_name for
			          Action Assignee notification to the full name of the action assignee.
               03-Aug-05 raluthra Bug 4527617. Replaced the usage of fnd_user.
                                  customer_id with fnd_user.person_party_id
                                  for R12 ATG Mandate.
	       10-Aug-05 rasinha  Bug# 4527911:
	                          1)Added the procedure close_notification to close an open action notification.
				  2)Modified the KEEP_OPEN procedure to avoid adding comments if it is already being done.
				  3)Modifed the procedure CANCEL_NOTIF_AND_ABORT_WF to find out open notification for an action
				    and canel the notification. This is called when an action is cancelled.
	       08-Sep-05 raluthra Bug 4565156. Added code for Manual NOCOPY Changes
                                  for usage of same variable for In and Out parameter.
               01-Feb-06 vgottimu Bug 4923945. Changed the cursor cur_ci_status_n_owner  query,
                                  pa_ci_list_v is replaced with the base table pa_control_items and
                                  included  table  hz_parties to get the owner name.
	       26-Apr-07 vvjoshi  Bug#5962401:Modified set_workflow_attributes procedure to set expiration date for adhoc role.
       	       25-Jun-07 rballamu Bug#6053648:Modified change_status_approved to initialize the application context.
			   17-8-09 anuragar Bug 8566495 Changes for E&C enchancement.
			   25-9-09 anuragar Bug 8942843 Passing attributes pertaining to PAWFCISC only
			   01-12-2009 anuragar Bug 8855304: Forward port for Bug#8673347 : Passes email_address to createAdhocRole.
									changes tagged by 8673347
=============================================================================*/

  G_USER_ID         CONSTANT NUMBER := FND_GLOBAL.user_id;


        /********************************************************************
        * Procedure     : start_workflow
        * Purpose       :
        *********************************************************************/
        Procedure  start_workflow
	 (
	    p_item_type         IN     VARCHAR2
	  , p_process_name      IN     VARCHAR2

	  , p_ci_id        IN     NUMBER

	  , x_item_key       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	  , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
          , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )
        IS

	   l_item_key NUMBER;

	   l_approval_role varchar2(30) := NULL;
	   l_role_users    varchar2(300) := NULL;
	   l_last_item_key VARCHAR2(200);

	   l_err_code NUMBER;
	   l_err_stage VARCHAR2(30);
	   l_err_stack VARCHAR2(240);

	   l_project_id NUMBER;
	   l_content_id NUMBER;
--Bug 8566495 Changes for E&C enhancement related to CR workflow


	   CURSOR get_last_workflow_info
	     IS
		SELECT MAX(item_key)
		  FROM pa_wf_processes
		  WHERE item_type = p_item_type
		  AND description = p_process_name
		  AND entity_key2 = p_ci_id
		  AND entity_key1 = l_project_id
		  AND  wf_type_code  = 'Control Item';

	     CURSOR get_project_id
	       IS
		  SELECT project_id
		    FROM pa_control_items
		    WHERE ci_id = p_ci_id;
        BEGIN

	   OPEN get_project_id;
	   FETCH get_project_id INTO l_project_id;
	   CLOSE get_project_id;

	   SELECT pa_workflow_itemkey_s.nextval
	     INTO l_item_key
	     from dual;

	   x_item_key := To_char(l_item_key);

	   x_return_status := FND_API.G_RET_STS_SUCCESS;


	   --debug_msg ( 'before WF_ENGINE createProcess: ' || p_Process_Name);

	   -- create the workflow process
	   WF_ENGINE.CreateProcess(    p_item_type
				     , x_item_key
				       , p_Process_Name);
	   --debug_msg ( 'after WF_ENGINE createProcess: key = '  || x_item_key);

	   pa_control_items_wf_client.start_workflow(
						p_item_type
						, p_process_name
						, x_item_key
						, p_ci_id
						, x_msg_count
						, x_msg_data
						, x_return_status
						);

	   IF x_return_status = FND_API.g_ret_sts_success then

	      -- cancle the last running workflow if any

	      OPEN get_last_workflow_info;
	      FETCH get_last_workflow_info INTO l_last_item_key;
	      IF get_last_workflow_info%found THEN
	      begin
	   -- abort this process if it is running
	      WF_ENGINE.AbortProcess(  p_Item_Type
				    , l_last_Item_Key
				       );
	      EXCEPTION
		 WHEN OTHERS THEN
		    NULL;
	      END;

	      END IF;
		  --Changes for bug 8942843 start
		  if p_item_type = 'PAWFCISC' then
--Bug 8566495 Changes for E&C enhancement related to CR workflow
			wf_engine.SetItemAttrText(itemtype => p_item_type,
					itemkey  => x_item_key,
					aname    => 'CI_TASK_INFO',
					avalue   =>
					'PLSQL:pa_control_items_workflow.show_task_details/'||
					p_ci_id);
			end if;
			--Changes for bug 8942843 end

	      --debug_msg_s1 ( 'before WF_ENGINE startProcess' );
	      --debug_msg_s1 ( 'startProcess: item_type = ' ||  p_item_type || ' item_key = ' || x_Item_Key );

	      WF_ENGINE.StartProcess(
				     p_Item_Type
				     , x_Item_Key
				     );
	     -- debug_msg_s1 ( 'after start Process: item_type = ' ||  p_item_type || ' item_key = ' || x_Item_Key );
	   END IF;

	   --debug_msg ( 'after WF_ENGINE startProcess' );

	     -- insert into pa_wf_process table

	   --debug_msg_s1 ('after workflow 1: isnertwf processes' || p_item_type);
	   --debug_msg_s1 ('after workflow 1: isnertwf processes' || l_item_key);

	   --debug_msg_s1 ( 'b4 get project id ' );

	   l_project_id :=  wf_engine.GetItemAttrNumber( p_item_type
                                      , l_item_key
                                      , 'PROJECT_ID'
							 );

	   --debug_msg_s1 ( 'startProcess: item_type = ' ||  l_project_id );

	   PA_WORKFLOW_UTILS.Insert_WF_Processes
                      (p_wf_type_code           => 'Control Item'
                       ,p_item_type              => p_item_type
                       ,p_item_key               => l_item_key
                       ,p_entity_key1            => l_project_id
                       ,p_entity_key2            => p_ci_id
                       ,p_description            => p_process_name
                       ,p_err_code               => l_err_code
                       ,p_err_stage              => l_err_stage
                       ,p_err_stack              => l_err_stack
                       );

	   IF l_err_code <> 0 THEN

	      PA_UTILS.Add_Message( p_app_short_name => 'PA'
				    ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
	      x_return_status := FND_API.G_RET_STS_ERROR;


	      -- abort the workflow process just launched, there is a problem
	      WF_ENGINE.AbortProcess(  p_Item_Type
				       , l_Item_Key
				       );

	   END IF;


        EXCEPTION

	   WHEN OTHERS THEN
	      --debug_msg ( 'Exception ' || substr(SQLERRM,1,2000)  );


	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END start_workflow;

	 /********************************************************************
        * Procedure     : Cancel_Workflow
        * Parameters IN :
        * Parameters OUT: Return Status
        * Purpose       :
        *********************************************************************/
        Procedure  Cancel_Workflow
	  (  p_Item_type         IN     VARCHAR2
	   , p_Item_key        IN     VARCHAR2
	   , x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
	   , x_msg_data        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )

	  IS


        BEGIN


        x_return_status := FND_API.G_RET_STS_SUCCESS;

	--debug_msg ( 'after client cancel_workflow call' );

	IF (x_return_status = FND_API.g_ret_sts_success) THEN
	   WF_ENGINE.AbortProcess(  p_Item_Type
				    , p_Item_Key
				    );

	   --debug_msg ( 'after WF_ENGINE abortProcess' );

	   --debug_msg ('before get task_id');

	END IF;


	EXCEPTION

	   WHEN OTHERS THEN
	      --debug_msg ( 'Exception in Cancel_Wf ' || substr(SQLERRM,1,2000) );

	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Cancel_workflow;

	PROCEDURE change_status_working
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_ci_id NUMBER := 0;
	     l_record_version_number NUMBER := 0;

	     l_return_status VARCHAR2(200);
	     l_msg_data VARCHAR2(200);
	     l_msg_count number;

	     l_num_of_actions NUMBER;


	BEGIN

           l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'CI_ID');




	    l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

	      pa_control_items_utils.ChangeCIStatus
	      (
	       p_validate_only=> 'F',
	       p_commit=>'T',

	       p_ci_id => l_ci_id,
	       p_status=>'CI_WORKING',

	       p_record_version_number=>l_record_version_number,
	       x_num_of_actions  => l_num_of_actions,
	       x_return_status=> l_return_status,
	       x_msg_count=>l_msg_count,
	       x_msg_data=> l_msg_data

	       );

	      IF l_return_status <> 'S' then

	      --debug_msg_s1('Error:  || ' || fnd_msg_pub.get(p_msg_index => 1,
				--			    p_encoded   => FND_API.G_FALSE));
	      NULL;

	      END IF;




	END ;


	PROCEDURE change_status_rejected
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_ci_id NUMBER := 0;
	     l_record_version_number NUMBER := 0;
	     l_name VARCHAR2(200);
	     l_return_status VARCHAR2(200);
	     l_msg_data VARCHAR2(200);
	     l_msg_count number;
	     l_comment VARCHAR2(2000);
	     l_num_of_actions NUMBER;
             l_status  VARCHAR2(30);

             cursor c_status(p_ci_id NUMBER, p_item_type VARCHAR2) is
           SELECT wf_failure_status_code
              FROM pa_project_statuses ps,
                   pa_control_items ci
              WHERE ci.ci_id = p_ci_id
                and ci.status_code = ps.project_status_code
                and ps.status_type = 'CONTROL_ITEM'
                and ps.workflow_item_type = p_item_type
                and ps.enable_wf_flag = 'Y'
                and ps.wf_failure_status_code is NOT NULL;

	BEGIN

           l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'CI_ID');

	   --debug_msg_s1 ('AAAAAAAAAAA  report rejected' || WF_ENGINE.context_text);

	     l_comment     := wf_engine.GetItemAttrText
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'COMMENT');

	      l_name :=  wf_engine.GetItemAttrText(  itemtype
								, itemkey
								, 'CI_APPROVER_NAME');


	       l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');


	    pa_workflow_history.save_comment_history (
				  itemtype
				  ,itemkey
				  ,'REJECT'
				  ,l_name ,
				  l_comment);



	    -- set notification party based on the notification type
	   pa_control_items_wf_client.set_notification_party
	     (itemtype,
	      itemkey,
	      'CI_REJECTED',
	      actid,
	      funcmode,
	      resultout
	      );


           /* Bug# 3297238 FP M changes  */
           open c_status(l_ci_id, itemtype);
           fetch c_status into l_status;
           close c_status;

	   	    -- debug_msg_s1 ('b4 reject the ci ' || l_return_status);
	    pa_control_items_utils.ChangeCIStatus
	      (
	       p_validate_only=> 'F',
	       p_commit=>'T',
	       p_ci_id => l_ci_id,
--	       p_status=>'CI_REJECTED', /* Bug# 3297238 FP M changes */
	       p_status=> l_status,   /* Bug# 3297238 FP M changes */
	       p_comment=> l_comment,
	       p_record_version_number=>l_record_version_number,
	       x_num_of_actions  => l_num_of_actions,
	       x_return_status=> l_return_status,
	       x_msg_count=>l_msg_count,
	       x_msg_data=> l_msg_data

	       );

	    	     --debug_msg_s1 ('after reject the ci ' || l_return_status);

		      IF l_return_status <> 'S' then

	      --debug_msg_s1('Error:  || ' || fnd_msg_pub.get(p_msg_index => 1,
							    --p_encoded   => FND_API.G_FALSE));
							    NULL;


	      END IF;

	END ;


	PROCEDURE change_status_approved
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_ci_id NUMBER := 0;
	     l_status VARCHAR2(30);
	     l_record_version_number NUMBER := 0;
	     l_name VARCHAR2(200);

	     l_return_status VARCHAR2(200);
	     l_msg_data VARCHAR2(200);
	     l_msg_count number;

	     l_comment VARCHAR2(2000);

	     l_num_of_actions NUMBER;

	      cursor c_status(p_ci_id NUMBER, p_item_type VARCHAR2) is
           SELECT wf_success_status_code
              FROM pa_project_statuses ps,
        	   pa_control_items ci
              WHERE ci.ci_id = p_ci_id
		and ci.status_code = ps.project_status_code
		and ps.status_type = 'CONTROL_ITEM'
		and ps.workflow_item_type = p_item_type
		and ps.enable_wf_flag = 'Y'
		and ps.wf_success_status_code is NOT NULL;

  -- Added for Bug 6053648
           cursor c_user_id(p_user_name fnd_user.user_name%type) is
            select user_id
            from fnd_user
            where user_name = p_user_name;

           l_user_id fnd_user.user_id%type;
   -- End for Bug 6053648


	BEGIN

           l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'CI_ID');


	  -- debug_msg_s1 ('AAAAAAAAAAA  report approved ' || WF_ENGINE.context_text);

	    l_comment     := wf_engine.GetItemAttrText
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'COMMENT');

	     l_name :=  wf_engine.GetItemAttrText(  itemtype
								, itemkey
						    , 'CI_APPROVER_NAME');

 -- Added for Bug 6053648
            l_user_id := fnd_global.user_id;
            -- If approved via E-Mail we need to set the application context explicitly
            if (l_user_id is null or
                l_user_id = 0 or
                l_user_id = -1) then
                  begin
                     open c_user_id(l_name);
                     fetch c_user_id into l_user_id;
                     close c_user_id;
                     fnd_global.apps_initialize(
                           user_id=>l_user_id,
                           resp_id=>fnd_global.resp_id,
                           resp_appl_id=>275);
                  end;
            end if;
   -- End for Bug 6053648


	   --  debug_msg_s1 ('AAAAAAAAAAA  report approved approver name' || l_name);

	      l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

	      IF l_name IS NOT NULL THEN

		 pa_workflow_history.save_comment_history (
							   itemtype
							   ,itemkey
							   ,'APPROVE'
							   ,l_name,
							   l_comment);
	      END IF;



	   -- set notification party based on the notification type



	   pa_control_items_wf_client.set_notification_party
	     (itemtype,
	      itemkey,
	      'CI_APPROVED',
	      actid,
	      funcmode,
	      resultout
	      );


	   --debug_msg_s1 ('b4 approve the ci ');

           /* Bug# 3297238 FP M changes  */
           open c_status(l_ci_id, itemtype);
           fetch c_status into l_status;
           close c_status;

	     pa_control_items_utils.ChangeCIStatus
	      (
	       p_validate_only=> 'F',
	       p_commit=>'T',
	       p_ci_id => l_ci_id,
--	       p_status=>'CI_APPROVED',    /* Bug# 3297238 FP M changes */
	       p_status=> l_status, /* Bug# 3297238 FP M changes */
	       p_comment=> l_comment,
	       p_record_version_number=>l_record_version_number,
	       x_num_of_actions  => l_num_of_actions,
	       x_return_status=> l_return_status,
	       x_msg_count=>l_msg_count,
	       x_msg_data=> l_msg_data

	       );


	     --debug_msg_s1 ('after approve the ci ' || l_return_status);

	       IF l_return_status <> 'S' then

	      --debug_msg_s1('Error:  || ' || fnd_msg_pub.get(p_msg_index => 1,
				--			    p_encoded   => FND_API.G_FALSE));

		  NULL;

	       END IF;


		 END ;


	        PROCEDURE is_approver_same_as_submitter(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

		  IS

		      l_proj_mgr_id NUMBER;
		      l_submitter_id NUMBER;
		      l_user_name VARCHAR2(200);

		        CURSOR get_user_name
			  IS
			     SELECT user_name
			       FROM fnd_user
			       WHERE user_id = FND_GLOBAL.user_id;

		BEGIN

		    l_proj_mgr_id     := wf_engine.GetItemAttrNumber
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'PROJ_MGR_ID');

		    l_submitter_id     := wf_engine.GetItemAttrNumber
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'SUBMITTED_BY_ID');

		    --debug_msg_s1 ('l_proj_mgr_id = ' || l_proj_mgr_id);
		     --debug_msg_s1 ('l_submitter_id = ' || l_submitter_id);


		    OPEN get_user_name;
		    FETCH get_user_name INTO l_user_name;
		    CLOSE get_user_name;

		    --debug_msg_s1('b4 save history');


		    pa_workflow_history.save_comment_history (
						    itemtype
						   ,itemkey
						   ,'SUBMIT'
						   , l_user_name
							,'');

		      IF l_submitter_id = l_proj_mgr_id THEN

			   wf_engine.SetItemAttrText(  itemtype
					  , itemkey
					  , 'CI_APPROVER_NAME'
					  , l_user_name);

			 resultout := wf_engine.eng_completed||':'||'T';
		       ELSE

			 resultout := wf_engine.eng_completed||':'||'F';
		      END IF;


		END;




	PROCEDURE check_status_change
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_ci_id NUMBER := 0;
	     l_status VARCHAR2(30);
	     l_ret VARCHAR2(240);

	     CURSOR get_status IS
		SELECT status_code
		  FROM pa_control_items
		  WHERE ci_id = l_ci_id;


	BEGIN

           l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'CI_ID');

	   OPEN get_status;
	   FETCH get_status INTO l_status;

	   CLOSE get_status;

	   wf_engine.SetItemAttrText
               ( itemtype,
                 itemkey,
                 'STATUS_CODE',
		 l_status);


           IF l_status = 'CI_APPROVED' THEN
              resultout := wf_engine.eng_completed||':'||'APPROVED';
	    ELSIF l_status = 'CI_REJECTED' THEN
              resultout := wf_engine.eng_completed||':'||'REJECTED';
	   END IF;


	   -- added by syao
	   -- set notification party based on the notification type
	   pa_control_items_wf_client.set_notification_party
	     (itemtype,
	      itemkey,
	      l_status,
	      actid,
	      funcmode,
	      l_ret
	      );


	END ;

	 PROCEDURE approval_request_post_notfy(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

	   IS
	 BEGIN

	    resultout:='COMPLETE:'||'SUCCESS';
	    --resultout := wf_engine.eng_completed||':'||'T';

	 END;

	 PROCEDURE forward_notification(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

		  IS

		      l_comment VARCHAR2(2000);
		      l_forward_to VARCHAR2(200);
		      l_forward_to_display_name VARCHAR2(200); -- Bug 4565156.
		      l_forward_to_name VARCHAR2(200);
		      l_name VARCHAR2(200);
		      l_user_id NUMBER;

		      l_error_msg VARCHAR2(2000);


		      CURSOR is_user_valid
			IS
			   SELECT user_id FROM
			     fnd_user
			     WHERE user_name = l_forward_to
			     and trunc(sysdate) between start_date and nvl(end_date, sysdate); /* Bug#3838957  */


		      CURSOR get_name
			IS
			  --   select party_name from
		    --(
		     select hp.party_name
		     from fnd_user fu,
		     hz_parties hp
		     where fu.user_name = l_forward_to --fnd_global.user_id
		     and fu.employee_id is null
		     and fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
		     and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate) /* Bug#3838957  */
		     union
		     select hp.party_name
		     from fnd_user fu,
		     hz_parties hp
		     where fu.user_name = l_forward_to--fnd_global.user_id
		     and fu.employee_id is not null
		     and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate) /* Bug#3838957  */
		     and 'PER:' || fu.employee_id = hp.orig_system_reference;
                      --);

            display_name VARCHAR2(2000);
            email_address VARCHAR2(2000);
            notification_preference VARCHAR2(2000);
            language VARCHAR2(2000);
            territory VARCHAR2(2000);
		BEGIN

		   --debug_msg_s1 ('call forward AAAAAAAAAAA' || funcmode);

		   IF funcmode = 'RUN' then
		    l_comment     := wf_engine.GetItemAttrText
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'COMMENT');

		    --debug_msg_s1 ('forward AAAAAAAAAAA  get approval comment' || funcmode);
		    --debug_msg_s1 ('forward AAAAAAAAAAA  get approval comment' || actid);


		    l_forward_to     := wf_engine.GetItemAttrText
		      ( itemtype       => itemtype,
			itemkey        => itemkey,
			aname          => 'FORWARD_TO');

		    l_forward_to_display_name := l_forward_to; -- Bug 4565156.

		    OPEN is_user_valid;
		    FETCH is_user_valid INTO l_user_id;
		    IF is_user_valid%notfound THEN
			    -- the forward to is invalid
		       fnd_message.set_name ('PO', 'PO_WF_NOTIF_INVALID_FORWARD');
		       l_error_msg := fnd_message.get;

		       wf_engine.SetItemAttrText
			 ( itemtype,
			   itemkey,
			   'WRONG_FORWARD',
			   l_error_msg);


		     ELSE
		       -- the forward is OK
		       -- 1. change the notification party
		       -- 2. save the comment to history table

		         wf_directory.getroleinfo(l_forward_to,display_name,
  email_address,notification_preference,language,territory);
		  if display_name is null THEN
		       --IF NOT wf_directory.useractive (l_forward_to) THEN

			  --debug_msg('Add user');

			  WF_DIRECTORY.CreateAdHocUser( name => l_forward_to
							, display_name => l_forward_to_display_name -- Bug 4565156.
							--, notification_preference => 'MAILTEXT'
							, EMAIL_ADDRESS =>'');
		       END IF;

		       --debug_msg_s1 ('forward AAAAAAAAAAA  get approval comment: forward to = ' || l_forward_to);

		       wf_engine.SetItemAttrText(  itemtype
						   , itemkey
							 , 'CI_APPROVER'
						   , l_forward_to);


		       OPEN get_name ;
		       FETCH get_name INTO l_forward_to_name;
			 CLOSE get_name;

			 l_name :=  wf_engine.GetItemAttrText(  itemtype
								, itemkey
								, 'CI_APPROVER_NAME');



		        wf_engine.SetItemAttrText(  itemtype
					  , itemkey
					  , 'CI_APPROVER_NAME'
					  , l_forward_to);



		       pa_workflow_history.save_comment_history (
						   itemtype
						   ,itemkey
						   ,'FORWARD'
						   ,l_name
					     ,l_comment);

		       wf_engine.SetItemAttrText
		      ( itemtype,
			itemkey       ,
			'COMMENT',
			''
			);

		          wf_engine.SetItemAttrText(  itemtype
						      , itemkey
						      , 'RESULT'
						      , '');

			  wf_engine.SetItemAttrText(  itemtype
						      , itemkey
						      , 'FORWARD_TO'
						      , '');

		    END IF;
		   END IF;


		    resultout:='COMPLETE:'||'SUCCESS';

		    --resultout := wf_engine.eng_completed||':'||'T';


		END;

		PROCEDURE show_clob_content
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
	  IS

	     l_content   clob;


	     CURSOR get_report_info IS
/*		SELECT pprv.report_content FROM
		  pa_progress_report_vers pprv
		  where
		  pprv.version_id  = document_id
		    AND pprv.object_type = 'PA_PROJECTS'*/
		    select PAGE_CONTENT from PA_PAGE_CONTENTS
		    where object_Type     = 'PA_CONTROL_ITEMS'
		    and pk1_value         = document_id;

	     l_size number;

	     l_chunk_size  pls_integer:=10000;
	     l_copy_size int;
	     l_pos int := 0;

	     l_line varchar2(30000) := '' ; -- Bug 2885704 Changed size from 10000 to 30000

		 --Bug 3787169
		 l_return_status varchar2(1);
		 l_msg_count     number;
		 l_msg_data      varchar2(2000);


	BEGIN

	   --debug_msg_s1 ('get clob content' || document_id);
	   open get_report_info;
	   fetch get_report_info into l_content;

	   IF (get_report_info%found) then
	      close get_report_info;

	      -- parse the retrieved clob data

	      l_size := dbms_lob.getlength(l_content);

	      --debug_msg_s1 ('get clob content size' || l_size);

	      l_pos := 1;
	      l_copy_size := 0;

	      --debug_msg_s1 ('in loop size 1' || l_copy_size);
	      --debug_msg_s1 ('in loop size 2' || l_chunk_size);

	      while l_copy_size < l_size loop

		 --debug_msg_s1 ('before read ');

		 dbms_lob.read(l_content,l_chunk_size,l_pos,l_line);

		 -- debug_msg_s1 (l_line);
		 --debug_msg_s1 ('in loop size 1' || l_copy_size);

		 dbms_lob.write(document,l_chunk_size,l_pos,l_line);

		 l_copy_size := l_copy_size + l_chunk_size;
		 l_pos := l_pos + l_chunk_size;
	      end loop;

		 /*
			Bug 3787169. The following api is called so as to clean the html for the class
		    attribute.
		 */

		 pa_workflow_utils.modify_wf_clob_content(
			 p_document			=>	document
			,x_return_status	=>  l_return_status
			,x_msg_count		=>  l_msg_count
			,x_msg_data			=>  l_msg_data
		 );

		 if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
			  WF_NOTIFICATION.WriteToClob(document, 'Report Content Generation failed');
			  dbms_lob.writeappend(document, 255, substr(Sqlerrm, 255));
		 end if;

	      --debug_msg_s1 ('total copy size' || l_copy_size);

	      --dbms_lob.writeappend(document, 5, '12345');
	    ELSE
	      close get_report_info;
	   END IF;


	   document_type := 'text/html';

	   --debug_msg_s1 ('end' );


	EXCEPTION
	   WHEN OTHERS THEN

	      --debug_msg_s1('Error '||TO_CHAR(SQLCODE)||': '||substr(Sqlerrm, 255));


	      WF_NOTIFICATION.WriteToClob(document, 'Report Content Generation failed');
	      dbms_lob.writeappend(document, 255, substr(Sqlerrm, 255));

	END show_clob_content;


/*==================================================================
   This api will start the workflow when passed with the required
   arguments.
   Bug 3297238. FP M changes.
 =================================================================*/


PROCEDURE START_NOTIFICATION_WF
   (  p_item_type		In		VARCHAR2
	,p_process_name	In		VARCHAR2
	,p_ci_id		     In		pa_control_items.ci_id%TYPE
	,p_action_id		In		pa_ci_actions.ci_action_id%TYPE
    ,x_item_key		Out		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status    Out       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count        Out       NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data         Out       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_item_key                      NUMBER;
l_last_item_key                 VARCHAR2(200);
l_project_id                    pa_projects_all.project_id%TYPE;
l_wf_type_code                  pa_wf_processes.wf_type_code%TYPE;
l_entity_key1                   pa_wf_processes.entity_key1%TYPE;
l_entity_key2                   pa_wf_processes.entity_key2%TYPE;

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(30);
l_err_stack                     VARCHAR2(240);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.START_NOTIFICATION_WF';
Invalid_Arg_Exc_CI              Exception;

l_content_id NUMBER := 0;
--cursor to obtain the project id.
CURSOR get_project_id(c_ci_id pa_control_items.ci_id%TYPE)
IS
SELECT  project_id
  FROM  pa_control_items
  WHERE ci_id = c_ci_id;

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'START_NOTIFICATION_WF',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_item_type = '|| p_item_type;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_process_name = '|| p_process_name;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_ci_id = '|| p_ci_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_action_id = '|| p_action_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF (p_item_type IS NULL) OR
        (p_process_name IS NULL) OR
        (p_ci_id IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_CI;
     END IF;


	OPEN get_project_id(p_ci_id);
	FETCH get_project_id INTO l_project_id;
	CLOSE get_project_id;

     --Identify the wf_type_code based on action_id parameter.
     if(p_action_id is NULL) then
          l_wf_type_code := 'Control Item';
          l_entity_key1  := l_project_id;
          l_entity_key2  := p_ci_id;
     else
          l_wf_type_code := 'Control Item Action';
          l_entity_key1  := l_project_id;
          l_entity_key2  := p_action_id;
     end if;

     -- Get the item key from sequence.
     SELECT pa_workflow_itemkey_s.nextval
	  INTO l_item_key
	  from dual;
	x_item_key := To_char(l_item_key);


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'x_item_key = '|| x_item_key;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;
     -- create the workflow process
	WF_ENGINE.CreateProcess(p_item_type
	          		   ,x_item_key
			             ,p_process_name);


     -- The following API will set all the required attributes for the workflow to function.

     pa_control_items_workflow.set_workflow_attributes(
                p_item_type         => p_item_type
               ,p_process_name      => p_process_name
               ,p_ci_id             => p_ci_id
               ,p_action_id         => p_action_id
               ,p_item_key          => x_item_key
               ,x_return_status     => x_return_status
               ,x_msg_count         => x_msg_count
               ,x_msg_data          => x_msg_data
     );


     IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Error calling pa_control_item_workflow.SET_WORKFLOW_ATTRIBUTES';
             pa_debug.write('START_NOTIFICATION_WF: ' || l_module_name,pa_debug.g_err_stage,l_debug_level5);

             PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
          END IF;
          RAISE Invalid_Arg_Exc_CI;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'returned from pa_control_items_workflow.set_workflow_attributes';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;


     WF_ENGINE.StartProcess(p_item_type
	    		            ,x_item_key);

	PA_WORKFLOW_UTILS.Insert_WF_Processes
                   (p_wf_type_code            => l_wf_type_code
                    ,p_item_type              => p_item_type
                    ,p_item_key               => l_item_key
                    ,p_entity_key1            => l_entity_key1
                    ,p_entity_key2            => l_entity_key2
                    ,p_description            => p_process_name
                    ,p_err_code               => l_err_code
                    ,p_err_stage              => l_err_stage
                    ,p_err_stack              => l_err_stack
                    );

	IF l_err_code <> 0 THEN
	   -- abort the workflow process just launched, there is a problem
	   WF_ENGINE.AbortProcess(p_Item_Type
			               ,l_Item_Key);

        --Log an error message and go to exception section.
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
 		 	              ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
	   x_return_status := FND_API.G_RET_STS_ERROR;
        Raise Invalid_Arg_Exc_CI;
	END IF;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting START_NOTIFICATION_WF';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_CI THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF get_project_id%ISOPEN THEN
          CLOSE get_project_id;
     END IF;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF get_project_id%ISOPEN THEN
          CLOSE get_project_id;
     END IF;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_CONTROL_ITEMS_WORKFLOW'
                    ,p_procedure_name  => 'START_NOTIFICATION_WF'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END START_NOTIFICATION_WF;

/*==================================================================
   The required arguments for the workflow are set in this API. This
   API also identifies to whom the notification has to be sent to.
   Bug 3297238. FP M changes.
 =================================================================*/
PROCEDURE set_workflow_attributes
   (  p_item_type		In		VARCHAR2
	,p_process_name	In		VARCHAR2
	,p_ci_id		     In		pa_control_items.ci_id%TYPE
	,p_action_id		In		pa_ci_actions.ci_action_id%TYPE
	,p_item_key		In		NUMBER
     ,x_return_status    Out       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count        Out       NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data         Out       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(30);
l_err_stack                     VARCHAR2(240);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.set_workflow_attributes';
Invalid_Arg_Exc_CI              Exception;

l_project_id                    pa_projects_all.project_id%TYPE;
l_url                           VARCHAR2(2000);
l_act_url                       VARCHAR2(2000);
l_project_name                  pa_projects_all.name%TYPE;
l_project_number                pa_projects_all.segment1%TYPE;
l_customer                      pa_project_lists_v.customer_name%TYPE;
l_project_manager               pa_project_lists_v.person_name%TYPE;
l_org                           pa_project_lists_v.carrying_out_organization_name%TYPE;
l_owner_id                      pa_control_items.owner_id%TYPE;

l_action_number                 pa_ci_actions_v.ci_action_number%TYPE;
l_action_request                pa_ci_actions_v.comment_text%TYPE;
l_action_requestor              pa_ci_actions_v.create_name%TYPE;
l_action_date_required          pa_ci_actions_v.date_required%TYPE;
l_assign_party_id               pa_ci_actions_v.assign_party_id%TYPE;
l_create_party_id               pa_ci_actions_v.create_party_id%TYPE;
l_action_status_code            pa_ci_actions_v.status_code%TYPE;
--FP.M.IB1 Sanity
l_action_closure_comment        pa_ci_actions_v.cancel_comment%TYPE;


l_role                          varchar2(30) := NULL;
l_role_users                    varchar2(30000) := NULL;
display_name                    VARCHAR2(2000);
email_address                   VARCHAR2(2000);
notification_preference         VARCHAR2(2000);
language                        VARCHAR2(2000);
territory                       VARCHAR2(2000);
l_priority_name                 pa_lookups.meaning%TYPE;
l_comment_text                  pa_ci_comments.comment_text%TYPE;
l_loop_var1                     NUMBER := 1;
l_record_version_number         NUMBER;
l_ci_owner_id                   pa_control_items.owner_id%TYPE;
l_ci_owner_name                 VARCHAR2(2000);
l_ci_status_code                pa_control_items.status_code%TYPE;
l_ci_status_name                VARCHAR2(2000);
l_action_type                   pa_ci_actions_v.action_type%TYPE;
l_action_type_code              pa_ci_actions_v.action_type_code%TYPE;
l_last_updated                  pa_ci_actions_v.last_update_date%TYPE;
l_action_status_meaning         pa_ci_actions_v.status_meaning%TYPE;
l_sign_off_req_flag             pa_ci_actions_v.sign_off_required_flag%TYPE;
l_sign_off_req_meaning          pa_ci_actions_v.sign_off_required_flag_meaning%TYPE;
l_role_display_name             per_all_people_f.full_name%TYPE;  --Added for bug 4049901
l_role_email_add 	            per_all_people_f.email_address%TYPE; --for bug 8673347
l_content_id NUMBER := 0;

-- This cursor gets the info about the control item.
CURSOR get_ci_info
IS
  SELECT
     pci.project_id,
     pci.date_required,
     pct.name ci_type_name,
     pct.short_name ci_type_sn,
     pci.ci_number,
     pci.owner_id,
     summary,
	 pci.description description,
	 pci.creation_date creation_date,
     priority_code,
     pcc.class_code classification,
     pci.record_version_number record_version_number,
     pl.meaning ci_type_class,
     pcb.ci_type_class_code
     FROM pa_control_items pci,
          pa_ci_types_tl pct,
          pa_ci_types_b pcb,
          pa_lookups pl,
          pa_class_codes pcc
     WHERE ci_id = p_ci_id
     and pci.ci_type_id = pct.ci_type_id
     and pl.lookup_code = pcb.ci_type_class_code
     AND pcb.ci_type_id = pct.ci_type_id
     and pl.lookup_type = 'PA_CI_TYPE_CLASSES'
     AND pcc.class_code_id = pci.classification_code_id;

--This cursor gets the info about the project.
CURSOR get_project_info(l_project_id number)
IS
  SELECT
     customer_name,
     person_name,
     carrying_out_organization_name
     FROM pa_project_lists_v
     WHERE project_id = l_project_id;

--This cursor gets the info about the action.
CURSOR cur_ci_action_info(c_action_id pa_ci_actions.ci_action_id%TYPE)
IS
  select ci_action_number,
         date_required,
         create_name,
         comment_text,
         assign_party_id,
         create_party_id,
         status_code,
         cancel_comment,
	 record_version_number,
	 action_type_code,
	 action_type,
	 last_update_date,
	 status_meaning,
	 sign_off_required_flag,
	 sign_off_required_flag_meaning--FP.M.IB1 Sanity
  from pa_ci_actions_v
  where ci_action_id = c_action_id;

--Bug 4923945 Begining of Code changes.
--This Cursor is added for the bug# 3691192 to get Ci Owner and Ci Status
CURSOR cur_ci_status_n_owner(p_ci_id  number)
IS
  select pci.status_code,
         pps.project_status_name,
	 pci.owner_id,
	 hzp.party_name
  from pa_control_items pci,
       pa_project_statuses pps,
       hz_parties hzp
  where pci.ci_id = p_ci_id AND
        pci.status_code=pps.project_status_code AND
        hzp.party_id = pci.owner_id;

--Bug 4923945 End of Code Changes.




--This cursor gets the users to whom the notification should be sent to.
CURSOR get_notification_list(c_owner_id pa_control_items.owner_id%TYPE)
IS
--select user_name, party_name, email_address
  --from (
     select fu.user_name, hp.party_name, hp.email_address
     from fnd_user fu,
          hz_parties hp
     where
          fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
          and hp.party_id = c_owner_id
	  and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate) /* Bug#3838957  */
     union
     select fu.user_name, hp.party_name, hp.email_address
     from
          fnd_user fu,
          hz_parties hp,
          per_all_people_f papf
     where
          fu.employee_id = Substr(hp.orig_system_reference, 5, Length(hp.orig_system_reference))
          AND 'PER:' = Substr(hp.orig_system_reference,1,4)
          and hp.party_id = c_owner_id
          and trunc(sysdate) between papf.EFFECTIVE_START_DATE and Nvl(papf.effective_end_date, Sysdate + 1)
	  and trunc(sysdate) between fu.start_date and nvl(fu.end_date, sysdate)  /* Bug#3838957  */
          and papf.person_id = fu.employee_id;
     --);

--This cursor helps to get meaning given the lookup type and code.
Cursor get_lookup_meaning(c_lookup_type pa_lookups.lookup_type%TYPE, c_lookup_code pa_lookups.lookup_code%TYPE)
IS
Select
     lkp.meaning
from
     pa_lookups lkp
where
     lkp.lookup_type = c_lookup_type
     and lkp.lookup_code = c_lookup_code;

--This cursor gets the change owner comment text.
Cursor get_comment_text(c_ci_id pa_control_items.ci_id%TYPE)
IS
select comment_text
from pa_ci_comments
where ci_comment_id =
(select max(ci_comment_id) from pa_ci_comments where ci_id = c_ci_id and type_code = 'CHANGE_OWNER');

-- This cursor gets the partyid of all the people involved in the hierarchy
Cursor get_parties_in_hierarchy(c_action_id pa_ci_actions.ci_action_id%TYPE)
               Is
	           select  PA_UTILS.get_party_id(created_by) party_id
	           from pa_ci_actions
	           start with ci_action_id = c_action_id
               connect by prior source_ci_action_id = ci_action_id;

 -- Added the cursor for bug 4049901
 -- This cursor gets the full name of the assignee of an action
  Cursor get_role_display_name( p_party_id per_all_people_f.party_id%TYPE)
 IS
    select full_name,email_address
    from per_all_people_f
    where party_id= p_party_id
    and sysdate between nvl(effective_start_date,sysdate) and nvl(effective_end_date,sysdate)
    and rownum=1;
-- Bug 8673347 added email_address to above cursor


 -- This table contains PartyId's of all involved in hirarchy
 type l_table is table of pa_control_items.owner_id%TYPE index by binary_integer;
 PartyId_Tbl l_table ;

 -- This table checks for duplicates of PartyId's of all involved in hirarchy
 type l_table_dupck is table of CHAR index by binary_integer;
 PartyId_Tbl_DupCk l_table_dupck;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'set_workflow_attributes',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage:= 'p_item_type = '|| p_item_type;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.g_err_stage:= 'p_process_name = '|| p_process_name;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.g_err_stage:= 'p_ci_id = '|| p_ci_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
     END IF;

     IF (p_item_type IS NULL) OR
        (p_process_name IS NULL) OR
        (p_ci_id IS NULL)
     THEN

          PA_UTILS.ADD_MESSAGE
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_CI;
     END IF;

     -- Set the workflow attributes.
     wf_engine.SetItemAttrText( p_item_type
                               ,p_item_key
                               ,'ITEM_TYPE'
                               ,p_item_type);

     wf_engine.SetItemAttrText( p_item_type
                               ,p_item_key
                               ,'ITEM_KEY'
                               ,p_item_key);

     wf_engine.SetItemAttrNumber( p_item_type
                                , p_item_key
                                , 'CI_ID'
                                , p_ci_id);

     FOR rec IN get_ci_info LOOP

	  pa_utils.getprojinfo(rec.project_id, l_project_number, l_project_name);
          l_owner_id := rec.owner_id;

          wf_engine.SetItemAttrNumber(p_item_type
                                    , p_item_key
                                    , 'PROJECT_ID'
                                    , rec.project_id);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'PROJECT_NAME'
                                    , l_project_name);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'PROJECT_NUMBER'
                                    , l_project_number);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'PROJECT'
                                    , l_project_name||'('||l_project_number||')');

          wf_engine.SetItemAttrDate(  p_item_type
                                    , p_item_key
                                    , 'DATE_REQUIRED'
                                    , rec.date_required);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'SUMMARY'
                                    , rec.summary);
          --Changes for bug 8942843 start
          if p_action_id is null
          then
		  wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'CI_DESCRIPTION'
                                    , rec.description);
			 wf_engine.SetItemAttrDate(  p_item_type
                                    , p_item_key
                                    , 'CI_CREATION_DATE'
                                    , rec.creation_date);
			end if;
          --Changes for bug 8942843 end
          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'CONTROL_ITEM_TYPE'
                                    , rec.ci_type_name);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'CONTROL_ITEM_TYPE_SN'
                                    , rec.ci_type_sn);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'CONTROL_ITEM_NUMBER'
                                    , rec.ci_number);

          wf_engine.SetItemAttrText(  p_item_type
                                    , p_item_key
                                    , 'CONTROL_ITEM_CLASS'
                                    , rec.ci_type_class);


          if (rec.priority_code is not null) then
               open get_lookup_meaning('PA_TASK_PRIORITY_CODE',rec.priority_code);
               fetch get_lookup_meaning into l_priority_name;
               close get_lookup_meaning;
          else
               l_priority_name := null;
          end if;
          wf_engine.SetItemAttrText( p_item_type
                                   , p_item_key
                                   , 'PRIORITY'
                                   , l_priority_name);

          wf_engine.SetItemAttrText( p_item_type
                                   , p_item_key
                                   , 'CLASSIFICATION'
                                   , rec.classification);

          -- set project manager, organization name and customer
          OPEN get_project_info(rec.project_id);
          FETCH get_project_info INTO l_customer,l_project_manager, l_org;

          wf_engine.SetItemAttrText( p_item_type
                                   , p_item_key
                                   , 'PROJECT_MANAGER'
                                   , l_project_manager);


          wf_engine.SetItemAttrText( p_item_type
                                   , p_item_key
                                   , 'ORGANIZATION'
                                   , l_org);

          wf_engine.SetItemAttrText( p_item_type
                                   , p_item_key
                                   , 'CUSTOMER'
                                   , l_customer);
          CLOSE get_project_info;

          --FP.M.IB1 - Set the url depending on the context. This is for the control item.
          --if (p_action_id is null) then
                --Bug 3974641. Replacing PA_CI_CI_REVIEW_LAYOUT AK region name with the xml file name CiCiReviewPG.
               l_url := 'JSP:/OA_HTML/OA.jsp?'||'page=/oracle/apps/pa/ci/webui/CiCiReviewPG' ||
               '&addBreadCrumb=N&paCiId='||p_ci_id || '&paProjectId=' || rec.project_id ||
               '&paCITypeClassCode=' || rec.ci_type_class_code|| '&paNotificationId=-&#NID-';

               wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'CI_LINK'
                                        , l_url);
          --end if;

          if (p_action_id is null) then
               open get_comment_text(p_ci_id);
               fetch get_comment_text into l_comment_text;
               close get_comment_text;


               wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'COMMENT'
                                        , l_comment_text);
          end if;
          if (p_action_id is not null) then
	       --Changes for the bug# 3691192 starts
	       -- these are the new attributes added in the workflow PAWFCIAC to
	       -- show Ci Status and Ci Owner in the notification
	       open cur_ci_status_n_owner(p_ci_id);
	       fetch cur_ci_status_n_owner into l_ci_status_code,
	                                        l_ci_status_name,
						l_ci_owner_id,
						l_ci_owner_name;
                close cur_ci_status_n_owner; /* Added for Bug#4124900 */

               wf_engine.SetItemAttrText(  p_item_type
                                         , p_item_key
                                         , 'CI_STATUS_CODE'
                                         , l_ci_status_code);

               wf_engine.SetItemAttrText(  p_item_type
                                         , p_item_key
                                         , 'CI_STATUS'
                                         , l_ci_status_name);

              wf_engine.SetItemAttrNumber(  p_item_type
                                         , p_item_key
                                         , 'CI_OWNER_ID'
                                         , l_ci_owner_id);

               wf_engine.SetItemAttrText(  p_item_type
                                         , p_item_key
                                         , 'CI_OWNER_NAME'
                                         , l_ci_owner_name);
               --Changes for the bug# 3691192 ends

               open cur_ci_action_info(p_action_id);
               fetch cur_ci_action_info into l_action_number,
                                             l_action_date_required,
                                             l_action_requestor,
                                             l_action_request,
                                             l_assign_party_id,
                                             l_create_party_id,
                                             l_action_status_code,
                                             l_action_closure_comment,
					     l_record_version_number,
					     l_action_type_code,
					     l_action_type,
					     l_last_updated,
					     l_action_status_meaning,
					     l_sign_off_req_flag,
					     l_sign_off_req_meaning;  --FP.M.IB1 Sanity

               wf_engine.SetItemAttrNumber(  p_item_type
                                         , p_item_key
                                         , 'ACTION_ID'
                                         , p_action_id);

               wf_engine.SetItemAttrNumber(  p_item_type
                                         , p_item_key
                                         , 'RECORD_VERSION_NUMBER'
                                         , l_record_version_number);

	       wf_engine.SetItemAttrNumber(  p_item_type
                                         , p_item_key
                                         , 'ACTION_NUMBER'
                                         , l_action_number);

               wf_engine.SetItemAttrText(  p_item_type
                                         , p_item_key
                                         , 'ACTION_REQUEST'
                                         , l_action_request);


               wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'ACTION_REQUESTOR'
                                        , l_action_requestor);

               wf_engine.SetItemAttrDate( p_item_type
                                        , p_item_key
                                        , 'ACTION_DATE_REQUIRED'
                                        , l_action_date_required);

	       wf_engine.SetItemAttrNumber(  p_item_type
                                         , p_item_key
                                         , 'ASSIGN_PARTY_ID'
                                         , l_assign_party_id);


	       --Changes for the bug# 3691192 starts
	       -- Follwing are the new Item Attributes added in the workflow PAWFCIAC
               wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'ACTION_TYPE_CODE'
                                        , l_action_type_code);

	       wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'ACTION_TYPE'
                                        , l_action_type);


	       wf_engine.SetItemAttrDate( p_item_type
                                        , p_item_key
                                        , 'SYSDATE'
                                        , sysdate);

	       wf_engine.SetItemAttrDate( p_item_type
                                        , p_item_key
                                        , 'LAST_UPDATE_DATE'
                                        , l_last_updated);

	       wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'ACTION_STATUS_CODE'
                                        , l_action_status_code);

	       wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'ACTION_STATUS'
                                        , l_action_status_meaning);

	       wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'SIGN_OFF_REQUESTED_FLAG'
                                        , l_sign_off_req_flag);

	       wf_engine.SetItemAttrText( p_item_type
                                        , p_item_key
                                        , 'SIGN_OFF_REQUESTED'
                                        , l_sign_off_req_meaning);



                -- --Changes for the bug# 3691192
		-- In the Notification a Take Action Link is added that will take user to the View Action Page which will have
		-- a Take Action button if the user has access to take Actions.

		    l_act_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=PA_CI_VIEW_ACTION_LAYOUT&akRegionApplicationId=275' ||
                    '&addBreadCrumb=N&paCiId='||p_ci_id || '&paProjectId=' || rec.project_id || '&paCiActionId='
                    || p_action_id || '&paCITypeClassCode=' || rec.ci_type_class_code || '&paNotificationId=-&#NID-';

	       --FP.M.IB1. The related application link should point to take action if action assignment
               --or view action if action closure.
               if(l_action_status_code = 'CI_ACTION_OPEN') then
                    /*l_act_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=PA_CI_TAKE_ACTION_LAYOUT&akRegionApplicationId=275' ||
                    '&addBreadCrumb=N&paCiId='||p_ci_id || '&paProjectId=' || rec.project_id || '&paCiActionId='
                    || p_action_id || '&paCITypeClassCode=' || rec.ci_type_class_code ||'&paNotificationId=-&#NID-';                    */
		    null;
               elsif(l_action_status_code = 'CI_ACTION_CLOSED') then
                    /*l_act_url := 'JSP:/OA_HTML/OA.jsp?akRegionCode=PA_CI_VIEW_ACTION_LAYOUT&akRegionApplicationId=275' ||
                    '&addBreadCrumb=N&paCiId='||p_ci_id || '&paProjectId=' || rec.project_id || '&paCiActionId='
                    || p_action_id || '&paCITypeClassCode=' || rec.ci_type_class_code || '&paNotificationId=-&#NID-';*/

                    --Set the closure comment if it is action closure.
                    wf_engine.SetItemAttrText( p_item_type
                                             , p_item_key
                                             , 'ACTION_CLOSURE_COMMENT'
                                             , l_action_closure_comment);
               end if;

	       -- New item attribute added in the workflow PAWFCIAC for the bug# 3691192
               if (l_act_url is not null) then
                    wf_engine.SetItemAttrText( p_item_type
                                             , p_item_key
                                             , 'CI_ACT_LINK'
                                             , l_act_url);
               end if;

               close cur_ci_action_info;
          end if;
     END LOOP;



     --All the required attributes have been set. Now identify to whom the
     --notification should be sent to.
     if(p_action_id is null) then
     --in this case send the notification to the item owner.
          PartyId_Tbl(l_loop_var1) := l_owner_id;
     else
          if (l_action_status_code = 'CI_ACTION_OPEN') then
               -- This action has just been created. notification should be sent to assignee and store at position 1 in PLSQL table.
               PartyId_Tbl(l_loop_var1) := l_assign_party_id;

          elsif(l_action_status_code = 'CI_ACTION_CLOSED' ) then
               -- This action has just been closed. Generate notification list for each of the party id.

               --Bug 3608031.
               l_loop_var1 := 0;

               for x in get_parties_in_hierarchy(p_action_id)
               LOOP
                    IF NOT(PartyId_Tbl_DupCk.exists( x.party_id)) THEN
                           PartyId_Tbl_DupCk(x.party_id) := 'Y';

                           --Bug 3608031
                           l_loop_var1 := l_loop_var1 + 1;

                           PartyId_Tbl(l_loop_var1) := x.party_id;
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'notification sent to :'||PartyId_Tbl(l_loop_var1);
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                    --Bug 3608031
                    --l_loop_var1 := l_loop_var1 + 1;
                    END IF;
               END LOOP;
         end if;

	 --Added for bug 4049901
	 -- Altering the Display name of the notification recipient for CI Action Workflow
	 open get_role_display_name(l_assign_party_id);
	 --Bug 8673347 added l_role_email_id
	 fetch get_role_display_name into l_role_display_name,l_role_email_add;
	 close get_role_display_name;
	 -- End of code added for 4049901

     end if;


     l_role := 'NOTFY_' ||p_item_type ||  p_item_key;

     --Added if condition for bug 4049901
     -- No need to alter the role display name for Control Item Workflow
     -- Changing the Role Display name only for CI Action Workflow
     if l_role_display_name is null then
        l_role_display_name := l_role;
     end if;
     --Changes for 8673347, passed email_address and notfn_pref as well.

     WF_DIRECTORY.CreateAdHocRole( role_name         => l_role
                                 , role_display_name => l_role_display_name  --Modified for bug 4049901
                                 , expiration_date   => sysdate+1
								 , email_address => l_role_email_add
								 , notification_preference=>'MAILHTML');   -- Set expiration_date for bug#5962401

    --for ctr in 1..(l_loop_var1-1) Bug 3608031
    for ctr in 1..l_loop_var1
    loop

        for v_party in get_notification_list(PartyId_Tbl(ctr))
           loop
              if (l_role_users is not null) then
                 l_role_users := l_role_users || ',';
              end if;

              -- Create adhoc users

              wf_directory.getroleinfo(v_party.user_name,
                                       display_name,
                                       email_address,
                                       notification_preference,
                                       language,
                                       territory);
              if display_name is null THEN

              WF_DIRECTORY.CreateAdHocUser( name           => v_party.user_name
                                           , display_name   => v_party.party_name
                                           , EMAIL_ADDRESS  => v_party.email_address);
              END IF;
              l_role_users := l_role_users || v_party.user_name;

           end loop;
    end loop;

     IF (l_role_users is NOT NULL) THEN
          WF_DIRECTORY.AddUsersToAdHocRole( l_role, l_role_users);

          wf_engine.SetItemAttrText(  p_item_type
                          , p_item_key
                          , 'CI_NOTIFICATION_PARTY'
                          , l_role);
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting set_workflow_attributes';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_CI THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF get_project_info%ISOPEN THEN
          CLOSE get_project_info;
     END IF;

     IF get_ci_info%ISOPEN THEN
          CLOSE get_ci_info;
     END IF;

     IF cur_ci_action_info%ISOPEN THEN
          CLOSE cur_ci_action_info;
     END IF;

     IF get_notification_list%ISOPEN THEN
          CLOSE get_notification_list;
     END IF;

     IF get_lookup_meaning%ISOPEN THEN
          CLOSE get_lookup_meaning;
     END IF;

     IF get_comment_text%ISOPEN THEN
          CLOSE get_comment_text;
     END IF;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF get_project_info%ISOPEN THEN
          CLOSE get_project_info;
     END IF;

     IF get_ci_info%ISOPEN THEN
          CLOSE get_ci_info;
     END IF;

     IF cur_ci_action_info%ISOPEN THEN
          CLOSE cur_ci_action_info;
     END IF;

     IF get_notification_list%ISOPEN THEN
          CLOSE get_notification_list;
     END IF;

     IF get_lookup_meaning%ISOPEN THEN
          CLOSE get_lookup_meaning;
     END IF;

     IF get_comment_text%ISOPEN THEN
          CLOSE get_comment_text;
     END IF;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_CONTROL_ITEMS_WORKFLOW'
                    ,p_procedure_name  => 'set_workflow_attributes'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END set_workflow_attributes;

PROCEDURE CLOSE_CI_ACTION (
            itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
    IS

    Cursor check_record_changed(p_ci_action_id number,p_record_version_number number) IS
    select rowid
    from pa_ci_actions
    where ci_action_id = p_ci_action_id
    and record_version_number = p_record_version_number
    for update;

    Cursor ci_action(p_ci_action_id number) IS
    select ci_id, type_code, assigned_to, date_required,
    sign_off_required_flag, source_ci_action_id, created_by, creation_date
    from pa_ci_actions
    where ci_action_id = p_ci_action_id;

    l_party_id number;
    l_created_by number;
    l_creation_date date;
    l_ci_id number;
    l_type_code varchar2(30);
    l_assigned_to number;
    l_date_required date;
    l_sign_off_required_flag varchar2(1);
    l_source_ci_action_id number;
    l_error_msg_code varchar2(30);
    l_rowid rowid;
    l_ci_comment_id number;
    l_ci_record_version_number number;
    l_num_of_actions number;
    l_comment_text varchar2(32767);
    l_ci_action_id number;
    l_record_version_number number;
    l_return_status VARCHAR2(1) :=fnd_api.g_ret_sts_success;
    l_msg_count    number;
    l_msg_data     varchar2(2000);
    l_user_sign_off  VARCHAR2(1):='N';
    l_assign_party_id NUMBER;   --added for bug# 3877985
    l_fnd_usr_id      NUMBER;   --added for bug# 3877985



     --bug 3297238
     l_item_key              pa_wf_processes.item_key%TYPE;

    Cursor getRecordVersionNumber IS
    select record_version_number
    from pa_control_items
    where ci_id = l_ci_id;

    -- Added the cursor for bug# 3877985 Issue# 2
    CURSOR get_fnd_usr( p_party_id NUMBER) IS
    select user_id
    from fnd_user
    where person_party_id = p_party_id
    and   sysdate between trunc(start_date) and nvl(trunc(end_date),sysdate)
    and rownum = 1;

    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_WORKFLOW.CLOSE_CI_ACTION');


        l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'CI_ID');

        l_ci_action_id := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'ACTION_ID');

	 l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

         l_comment_text     := wf_engine.GetItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'COMMENT');

         l_comment_text     := wf_engine.GetItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'COMMENT');
         --Added for Bug# 3802238
         l_user_sign_off     := wf_engine.GetItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'SIGN_OFF');

         l_assign_party_id := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'ASSIGN_PARTY_ID');

	SAVEPOINT CLOSE_CI_ACTION;

        -- Validate the Input Values
        OPEN ci_action(l_ci_action_id);
        FETCH ci_action INTO l_ci_id, l_type_code, l_assigned_to,
        l_date_required, l_sign_off_required_flag, l_source_ci_action_id,
        l_created_by, l_creation_date;
	IF ci_action%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_NO_ACTION_FOUND');
	        resultout := wf_engine.eng_completed||':'||'F';
            CLOSE ci_action;
            return;
        END IF;

        --LOCK the ROW
	OPEN check_record_changed(l_ci_action_id,l_record_version_number);
        FETCH check_record_changed INTO l_rowid;
        IF check_record_changed%NOTFOUND THEN
		PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	       resultout := wf_engine.eng_completed||':'||'F';
            CLOSE check_record_changed;
            return;
        END IF;

	if (check_record_changed%ISOPEN) then
            CLOSE check_record_changed;
        end if;

	--Added for bug# 3877985 Issue# 2
	if (l_sign_off_required_flag = 'N') then
	   l_user_sign_off := 'N';
	end if;

	--Added for bug# 3877985.
	--Fetching the fnd user_id for the action asignee to update who columns
	OPEN get_fnd_usr( l_assign_party_id);
	FETCH get_fnd_usr INTO l_fnd_usr_id;
	CLOSE get_fnd_usr;
        PA_CI_ACTIONS_PKG.UPDATE_ROW(
            P_CI_ACTION_ID => l_ci_action_id,
            P_CI_ID => l_ci_id,
            P_STATUS_CODE => 'CI_ACTION_CLOSED',
            P_TYPE_CODE => l_type_code,
            P_ASSIGNED_TO => l_assigned_to,
            P_DATE_REQUIRED => l_date_required,
            P_SIGN_OFF_REQUIRED_FLAG => l_sign_off_required_flag,
            P_DATE_CLOSED => sysdate,
            P_SIGN_OFF_FLAG => l_user_sign_off,
            P_SOURCE_CI_ACTION_ID => l_source_ci_action_id,
            P_LAST_UPDATED_BY => l_fnd_usr_id,   --Modified for bug# 3877985
            P_CREATED_BY => l_created_by,
            P_CREATION_DATE => l_creation_date,
            P_LAST_UPDATE_DATE => sysdate,
            P_LAST_UPDATE_LOGIN => l_fnd_usr_id, --Modified for bug# 3877985
            P_RECORD_VERSION_NUMBER => l_record_version_number);

        if (l_comment_text IS NULL) THEN
		l_comment_text := ' ';
	end if;
        PA_CI_ACTIONS_PVT.ADD_CI_COMMENT(
                p_api_version  =>  1.0,
                p_init_msg_list => fnd_api.g_true,
                p_commit => FND_API.g_false,
                p_validate_only => FND_API.g_false,
                p_max_msg_count => FND_API.g_miss_num,
                p_ci_comment_id => l_ci_comment_id,
                p_ci_id => l_ci_id,
                p_type_code => 'CLOSURE',
                p_comment_text => l_comment_text,
                p_ci_action_id => l_ci_action_id,
                p_created_by   => l_fnd_usr_id,      --Added for bug# 3877985
                p_last_updated_by => l_fnd_usr_id,   --Added for bug# 3877985
                p_last_update_login => l_fnd_usr_id, --Added for bug# 3877985
                x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
                );

	OPEN getRecordVersionNumber;
	FETCH getRecordVersionNumber into l_ci_record_version_number;
	CLOSE getRecordVersionNumber;

        If (l_return_status = fnd_api.g_ret_sts_success) then

        	PA_CONTROL_ITEMS_PVT.UPDATE_NUMBER_OF_ACTIONS (
                 p_api_version  =>  1.0,
                 p_init_msg_list => fnd_api.g_true,
                 p_commit => FND_API.g_false,
                 p_validate_only => FND_API.g_true,
                 p_max_msg_count => FND_API.g_miss_num,
                 p_ci_id =>l_CI_ID,
       		 p_num_of_actions => -1,
		 p_record_version_number =>l_ci_record_version_number,
		 x_num_of_actions => l_num_of_actions,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 p_last_updated_by => l_fnd_usr_id,  --Added for bug# 3877985
                 p_last_update_login => l_fnd_usr_id --Added for bug# 3877985
		 );
	end if;


       -- Commit the changes if requested
        if l_return_status = fnd_api.g_ret_sts_success then
            commit;
	    resultout := wf_engine.eng_completed||':'||'T';
        end if;
	commit;


    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CLOSE_CI_ACTION;
        resultout := wf_engine.eng_completed||':'||'F';
    WHEN OTHERS THEN
        ROLLBACK TO CLOSE_CI_ACTION;
        resultout := wf_engine.eng_completed||':'||'F';
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_WORKFLOW',
                               p_procedure_name => 'CLOSE_CI_ACTIONS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END CLOSE_CI_ACTION;

PROCEDURE KEEP_OPEN (
            itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
    IS

    Cursor ci_action(p_ci_action_id number) IS
    select ci_id, type_code, assigned_to, date_required,
    sign_off_required_flag, source_ci_action_id, created_by, creation_date
    from pa_ci_actions
    where ci_action_id = p_ci_action_id;

    -- Added the cursor for bug# 3877985 Issue# 2
    CURSOR get_fnd_usr( p_party_id NUMBER) IS
    select user_id
    from fnd_user
    where person_party_id = p_party_id
    and   sysdate between trunc(start_date) and nvl(trunc(end_date),sysdate)
    and rownum = 1;

    -- Added the cursor for bug# 4527911
    cursor is_comment_inserted_cur(p_ci_action_id NUMBER) IS
    select 1
    from pa_ci_comments
    where ci_action_id = p_ci_action_id
    and  type_code='UNSOLICITED';

    l_party_id number;
    l_created_by number;
    l_creation_date date;
    l_ci_id number;
    l_type_code varchar2(30);
    l_assigned_to number;
    l_date_required date;
    l_sign_off_required_flag varchar2(1);
    l_source_ci_action_id number;
    l_error_msg_code varchar2(30);
    l_rowid rowid;
    l_ci_comment_id number;
    l_ci_record_version_number number;
    l_num_of_actions number;
    l_comment_text varchar2(32767);
    l_ci_action_id number;
    l_record_version_number number;
    l_return_status VARCHAR2(1) :=fnd_api.g_ret_sts_success;
    l_msg_count    number;
    l_msg_data     varchar2(2000);
    l_assign_party_id NUMBER;   --added for bug# 3877985
    l_fnd_usr_id      NUMBER;   --added for bug# 3877985
    l_num_var   NUMBER;



     --bug 3297238
     l_item_key              pa_wf_processes.item_key%TYPE;

    Cursor getRecordVersionNumber IS
    select record_version_number
    from pa_control_items
    where ci_id = l_ci_id;
    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_WORKFLOW.KEEP_OPEN');



        l_ci_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'CI_ID');

        l_ci_action_id := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'ACTION_ID');

	 l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

         l_comment_text     := wf_engine.GetItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'COMMENT');

         l_assign_party_id := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'ASSIGN_PARTY_ID');


	SAVEPOINT KEEP_OPEN;

        -- Validate the Input Values
        OPEN ci_action(l_ci_action_id);
        FETCH ci_action INTO l_ci_id, l_type_code, l_assigned_to,
        l_date_required, l_sign_off_required_flag, l_source_ci_action_id,
        l_created_by, l_creation_date;
        IF ci_action%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_NO_ACTION_FOUND');
	        resultout := wf_engine.eng_completed||':'||'F';
            CLOSE ci_action;
            return;
        END IF;


        if (l_comment_text IS NULL) THEN
		l_comment_text := ' ';
	end if;

	--Fetching the fnd user_id for the action asignee to update who columns
	OPEN get_fnd_usr( l_assign_party_id);
	FETCH get_fnd_usr INTO l_fnd_usr_id;
	CLOSE get_fnd_usr;

	/* Code added for bug#  4527911
	There are two ways in which this api can be called:
	 1) When user takes keep open action from the workflow notification.
	 2) When user takes keep open action from take action page. When the notification result is set to
	    KEEP_OPEN from backend then again this api is called by the workflow system.
	 In case 2 the user comment will already be inserted in PA_CI_COMMENTS from the application, so no need to insert it again.
	 IF there is already a line in pa_ci_comments for the action with type_code UNSOLICITED it means that the comment is already
	 inserted.*/


	OPEN is_comment_inserted_cur(l_ci_action_id);
	FETCH is_comment_inserted_cur into l_num_var;
	IF is_comment_inserted_cur%NOTFOUND THEN
	   CLOSE is_comment_inserted_cur;
	   PA_CI_ACTIONS_PVT.ADD_CI_COMMENT(
                p_api_version  =>  1.0,
                p_init_msg_list => fnd_api.g_true,
                p_commit => FND_API.g_false,
                p_validate_only => FND_API.g_false,
                p_max_msg_count => FND_API.g_miss_num,
                p_ci_comment_id => l_ci_comment_id,
                p_ci_id => l_ci_id,
                p_type_code => 'UNSOLICITED',
                p_comment_text => l_comment_text,
                p_ci_action_id => l_ci_action_id,
                p_created_by   => l_fnd_usr_id,       --Added for bug# 3877985
                p_last_updated_by => l_fnd_usr_id,    --Added for bug# 3877985
                p_last_update_login => l_fnd_usr_id,  --Added for bug# 3877985
		x_return_status => l_return_status,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data
                );


           if l_return_status = fnd_api.g_ret_sts_success then
             commit;
	     resultout := wf_engine.eng_completed||':'||'T';
           end if;
	   commit;
	ELSE
	   CLOSE is_comment_inserted_cur;
	END IF;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO KEEP_OPEN;
        resultout := wf_engine.eng_completed||':'||'F';
    WHEN OTHERS THEN
        ROLLBACK TO KEEP_OPEN;
        resultout := wf_engine.eng_completed||':'||'F';
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_WORKFLOW',
                               p_procedure_name => 'KEEP_OPEN',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END KEEP_OPEN;

/***********************************************************************************
   Modified this procedure for Bug# 4527911
   This procedure is called when an action is cancelled from Action list Page.
   A new parameter p_ci_action_id is being added in the procedure and the parameters
   p_item_type,p_item_key and p_nid has been removed as the itme_type, item_key and
   notification_id is being derived in the procedure itself using the parameter
   p_ci_action_id
***********************************************************************************/
PROCEDURE cancel_notif_and_abort_wf(
      p_ci_action_id    IN     NUMBER,
      x_msg_count       OUT  NOCOPY  NUMBER   ,
      x_msg_data        OUT  NOCOPY  VARCHAR2 ,
      x_return_status   OUT  NOCOPY  VARCHAR2 )

IS
cursor get_open_notification(p_action_id VARCHAR2)
IS
  select wfi.notification_id,
         wfi.item_type,
         wfi.item_key
  from pa_wf_processes pwp,
       wf_item_activity_statuses_v wfi
  where pwp.entity_key2=p_action_id
  and pwp.item_type='PAWFCIAC'
  and wfi.item_type = pwp.item_type
  and wfi.item_key = pwp.item_key
  and wfi.activity_type_code='NOTICE'
  and wfi.activity_status_code='NOTIFIED';

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    for nid in get_open_notification(to_char(p_ci_action_id))
    loop
      WF_NOTIFICATION.CANCEL
      ( nid => to_number(nid.notification_id),
        cancel_comment => null
      );

      Cancel_Workflow
      (  p_Item_type => nid.item_type,
         p_Item_key => nid.item_key,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status
      );
    end loop;


EXCEPTION

     WHEN OTHERS THEN
        x_msg_count := 1;
        x_msg_data := substr(SQLERRM,1,2000);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cancel_notif_and_abort_wf;



/***********************************************************************************
   Added this procedure for Bug# 4527911
   This procedure is called when any action is taken from the Take Action Page.
   Here as per the action taken on take action page the Open action notification
   is closed with appropriate result.
   1) If on take action page the Action is Closed then the notification is also
      closed with result 'BBB_CLOSE'.If user provides a comment or sign-off then
      that also is updated in the notification.
   2) If on take action page the Action is kept open then the notification is
      closed with result 'AAA_KEEP_OPEN'.If user provides a comment or sign-off
      then that also is updated in the notification.
   3) If on take action page the Action is reassigned then the notification is
      closed with result 'BBB_CLOSE'
***********************************************************************************/
PROCEDURE close_notification(
      p_item_type       in     VARCHAR2,
      p_item_key        in     VARCHAR2,
      p_nid             in     NUMBER,
      p_action          in     VARCHAR2,
      p_sign_off_flag   in     VARCHAR2,
      p_response        in     VARCHAR2,
      x_msg_count       OUT  NOCOPY  NUMBER    ,
      x_msg_data        OUT  NOCOPY  VARCHAR2  ,
      x_return_status   OUT  NOCOPY  VARCHAR2  )

IS
l_sign_off_requested   VARCHAR2(1);

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_sign_off_requested:= wf_engine.GetItemAttrText
                         ( itemtype       => p_item_type,
                           itemkey        => p_item_key,
                           aname          => 'SIGN_OFF_REQUESTED_FLAG');


    if 	l_sign_off_requested = 'Y' then
       wf_notification.setAttrText(p_nid, 'SIGN_OFF',p_sign_off_flag);
    end if;

    wf_notification.setAttrText(p_nid, 'COMMENT', p_response);

    if p_action in ('C','R') then
       wf_notification.setAttrText(p_nid, 'RESULT', 'BBB_CLOSE');
    else
       wf_notification.setAttrText(p_nid, 'RESULT', 'AAA_KEEP_OPEN');
    end if;

    wf_notification.respond(p_nid, null, fnd_global.user_name);


EXCEPTION

     WHEN OTHERS THEN
	x_msg_count := 1;
	x_msg_data := substr(SQLERRM,1,2000);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END close_notification;


  PROCEDURE show_task_details
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, -- 4537865
	   document_type IN OUT NOCOPY VARCHAR2) -- 4537865

	  IS

	     CURSOR c_ci_task_info IS
        select ppe.element_number task_number,ppe.name task_name,ppe.description description,
pvsch.scheduled_start_date start_date,pvsch.scheduled_finish_date finish_date,
hz.party_name approver_name
from pa_proj_elements ppe,pa_proj_element_versions ppev,
pa_proj_elem_ver_schedule pvsch,fnd_user fu, hz_parties hz
where ppe.proj_element_id = ppev.proj_element_id
and pvsch.element_version_id = ppev.element_version_id
and ppe.task_approver_id=fu.user_id
and fu.person_party_id=hz.party_id
and ppe.proj_element_id in
(
Select distinct task_id from
          pa_resource_assignments pra where
          budget_version_id in (
           select budget_version_id from pa_budget_versions where ci_id =document_id)
        and exists (select 1
                  from pa_proj_elements ppe,
                       pa_proj_element_versions ppev,
                       pa_object_relationships por
                  where ppe.proj_element_id = pra.task_id
                  and ppe.project_id = pra.project_id
                  and ppe.link_task_flag = 'Y'
                  and ppe.type_id = 1
                  and ppev.proj_element_id = ppe.proj_element_id
                  and por.object_id_to1 = ppev.element_version_id
                  and por.object_type_to = 'PA_TASKS'
                  and por.relationship_type = 'S'
                  and ppev.financial_task_flag = 'Y')
        and not exists (select 1 from pa_tasks where task_id = pra.task_id and project_id = pra.project_id)
        );


	     	     l_index1 NUMBER;


	BEGIN



	   document := '<table cellpadding="0" cellspacing="0" border="0" width="100%" summary="">'
 	     || '<tr><td width="100%"  > <font face="Tahoma"  color=#3c3c3c class="OraHeaderSub"> '
 	     || '<B>Task Information</td></tr></table>';



	   document := document ||
	     '<table cellSpacing=1 cellPadding=3 width="90%" border=0 bgColor=white summary=""><tr>
 <TH  class=tableheader width=5%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Task Number</font>
 </TH> <TH class=tableheader width=35%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Task Name</font>
 </TH> <TH class=tableheader width=15%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Transaction Start</font>
 </TH> <TH class=tableheader  width = 15%  ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Transaction Finish</font>
 </TH> <TH class=tableheader width=55%   ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Description</font>
 </TH> <TH class=tableheader width=55%   ALIGN=left bgcolor=#cfe0f1><font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">Approver</font>
 </TH></TR> ';

	     FOR rec IN c_ci_task_info  LOOP

		document := document ||
		  '<TR BGCOLOR="#ffffff" ><TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.task_number || '</font></TD>';

		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.task_name || '</font></TD>';
		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.start_date || '</font></TD>';
		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.finish_date || '</font></TD>';
				document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.description || '</font></TD>';
		document := document || '<TD  class=approvalhistdata VALIGN=CENTER ALIGN=LEFT bgcolor=#f2f2f5> <font size="2" color=#3c3c3c face="Tahoma, Arial, Helvetica, Geneva">' || rec.approver_name || '</font></TD></tr>';


	   END LOOP;


	   document := document ||'</table><br><br>';

	   --debug_msg_s1('Docu = ' || document);

 	   document_type := 'text/html';

	-- 4537865
	EXCEPTION
		WHEN OTHERS THEN
		document := 'An Unexpected Error has occured' ;
		document_type := 'text/html';
		-- RAISE not needed here.
	END show_task_details;
END pa_control_items_workflow;


/
