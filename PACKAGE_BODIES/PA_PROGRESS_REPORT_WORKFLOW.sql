--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_REPORT_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_REPORT_WORKFLOW" as
/* $Header: PAPRWFPB.pls 120.9.12000000.2 2007/04/26 17:17:16 vvjoshi ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PAPRWFPB.pls
 DESCRIPTION :
               This file creates package procedures that are called to
               execute each activity in the Progress Status Workflow.



 HISTORY     : 06/22/00 SYAO Initial Creation
               17/02/04 sukhanna Bug : 3448380
                        Added check on assignment_type for CWK Changes.
               31/05/04 sukhanna  Removing the covering select clause in the
                                  cursor definiton of  get_name
               16/06/04 sulkumar  Bug 3629793: Commented code containing
	                          summary_version_number.
               27/08/04 sanantha  Bug 3787169. call the api modify_wf_clob_content
	       06/09/04 smekala	  Bug 3848024. Stopping notifications to end dated users
	       28/09/04 smekala   Bug 3905748  Closing the cursors.
	       09/02/05 rvelusam  Bug 4165780 Changed attribute 'FORWARD_TO' to
	                          FORWARD_TO_USERNAME_RESPONSE and changed the value set
				  for REPORT_APPROVER_USER_NAME.
               08/05/05 raluthra  Bug 4527617. Replaced fnd_user.customer_id with
	                          fnd_user.person_party_id for R12 ATG Mandate fix.
	       08/05/05 raluthra  Bug 4358517: Changed the definition of
	                          l_org local variable from VARCHAR2(60) to
				  pa_project_lists_v.carrying_out_organization_name%TYPE
	       08/09/05 raluthra  Bug 4565156. Added code for Manual NOCOPY Changes
                                  for usage of same variable for In and Out parameter.
	       06/02/06 posingha  Bug 4940945 Changed the query to base tables instead of view
                                  to improve performance.
               31/03/06 posingha  Bug 5027098 Added code to set the 'From' role attribute
                                  value for notifications.
               19/04/06 sukhanna  Bug 5173760. Did changes for swan UI. Changed these color codes
                                  replaced #cccc99 with #cfe0f1
                                  Replaced #336699 with #3c3c3c
                                  Replaced #f7f7e7 with #f2f2f5
               26/06/06 sukhanna  Bug 5357187. Did changes for swan UI. Changed these color codes
                                  replaced #cccc99 with #cfe0f1
                                  Replaced #336699 with #3c3c3c
                                  Replaced #f7f7e7 with #f2f2f5
	       26/04/07 vvjoshi	  Bug#5962401: Modified the expiration date for adhoc roles in
				  CreateAdhocRole procedure call.
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

	  , p_version_id        IN     NUMBER

	  , x_item_key       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	  , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
          , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )
        IS

	   l_project_name VARCHAR2(30);

	   l_item_key NUMBER;

	   l_task_num    VARCHAR2(25);
	   l_task_name   VARCHAR2(20);
	   l_person_id     NUMBER;
	   l_name        VARCHAR2(250);
	   l_status_code VARCHAR2(30);
	   l_approval_role varchar2(30) := NULL;
	   l_role_users    varchar2(30000) := NULL;
	   l_last_item_key NUMBER;

	     CURSOR get_last_workflow_info
	     IS
		SELECT MAX(item_key)
		  FROM pa_wf_processes, pa_progress_report_vers pprv
		  WHERE item_type = p_item_type
		  AND description = p_process_name
		  AND pprv.version_id = p_version_id
		  AND entity_key1 = pprv.object_id
		  AND pprv.object_type = 'PA_PROJECTS'
		  AND wf_type_code = 'Progress Report'
		  AND entity_key2 = p_version_id;

        BEGIN

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

	   pa_report_workflow_client.start_workflow(
						p_item_type
						, p_process_name
						, x_item_key
						, p_version_id
						, x_msg_count
						, x_msg_data
						, x_return_status
						);

	   IF x_return_status = FND_API.g_ret_sts_success then

	      --debug_msg ( 'before WF_ENGINE startProcess' );
	      --debug_msg ( 'startProcess: item_type = ' ||  p_item_type || ' item_key = ' || x_Item_Key );


	     OPEN get_last_workflow_info;
	     FETCH get_last_workflow_info INTO l_last_item_key;

	     --debug_msg_s1 ('get abort AAAAAAAAAA' || To_char(l_last_item_key));

	      IF get_last_workflow_info%found THEN

	      begin

		 --debug_msg_s1 ('abort AAAAAAAAAA' || p_item_type);

		 --debug_msg_s1 ('abort AAAAAAAAAA' || To_char(l_last_item_key));
		 WF_ENGINE.AbortProcess(  p_Item_Type
					  , l_last_Item_Key
					  );
	      EXCEPTION
		 WHEN OTHERS THEN
		    --debug_msg_s1 ('exception');
		    NULL;
	      END;

	      END IF;

	      CLOSE get_last_workflow_info;      -- Bug #3905748

	      WF_ENGINE.StartProcess(
				     p_Item_Type
				     , x_Item_Key
				     );
	   END IF;

	   --debug_msg ( 'after WF_ENGINE startProcess' );


        EXCEPTION

	   WHEN OTHERS THEN
	      --debug_msg ( 'Exception ' || substr(SQLERRM,1,2000)  );


	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	      RAISE;

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
	     l_task_id NUMBER := 0;
	     l_project_id NUMBER := 0;

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
	      RAISE;
        END Cancel_workflow;

	 /********************************************************************
        * Procedure     : get_Workflow_URL
        * Parameters IN :
        * Parameters OUT: Return Status
        * Purpose       :
        *********************************************************************/
        Procedure  Get_Workflow_Url
	  (
	   p_ItemType         IN     VARCHAR2
	   , p_ItemKey           IN     VARCHAR2
	   , x_URL               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	   , x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
	   , x_msg_data        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	   )

	IS

        BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;


	--debug_msg ('before web url = ');

        x_URL := wf_monitor.getDiagramURL( wf_core.translate('WF_WEB_AGENT')
                                          , p_ItemType
                                          , p_ItemKey
                                          , 'NO'
                                          );

	--debug_msg ('web url = ' || x_url);


        EXCEPTION

	   WHEN OTHERS THEN
	      --debug_msg ( 'Exception in Get_Wf_Url ' || substr(SQLERRM,1,2000) );
	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      RAISE;

        END get_workflow_url;

	PROCEDURE check_progress_status
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_version_id NUMBER := 0;
	     l_status VARCHAR2(30);
	     l_ret VARCHAR2(240);
             l_name        fnd_user.user_name%type;   -- Added for bug 5027098

	     CURSOR get_progress_status IS
		SELECT report_status_code
		  FROM pa_progress_report_vers
		  WHERE version_id = l_version_id;


	BEGIN

           l_version_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'VERSION_ID');

	   OPEN get_progress_status;
	   FETCH get_progress_status INTO l_status;

	   CLOSE get_progress_status;

	   wf_engine.SetItemAttrText
               ( itemtype,
                 itemkey,
                 'REPORT_STATUS',
		 l_status);
           /* Code addition for bug 5027098 starts */
           l_name :=  wf_engine.getItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'REPORT_APPROVER_USER_NAME');
           /* Code addition for bug 5027098 ends */

           IF l_status = 'PROGRESS_REPORT_PUBLISHED' THEN
              resultout := wf_engine.eng_completed||':'||'PUBLISHED';
	    ELSIF l_status = 'PROGRESS_REPORT_REJECTED' THEN
           /* Code addition for bug 5027098 starts */
              wf_engine.SetItemAttrText
                   ( itemtype,
                     itemkey,
                     'FROM_ROLE_VALUE',
                     l_name);
           /* Code addition for bug 5027098 ends */
              resultout := wf_engine.eng_completed||':'||'REJECTED';
	    ELSIF l_status = 'PROGRESS_REPORT_APPROVED' THEN

            /* Code addition for bug 5027098 starts */
               wf_engine.SetItemAttrText
                   ( itemtype,
                     itemkey,
                     'FROM_ROLE_VALUE',
                     l_name);
            /* Code addition for bug 5027098 ends */
              resultout := wf_engine.eng_completed||':'||'APPROVED';
	    ELSIF l_status = 'PROGRESS_REPORT_CANCELED' THEN
              resultout := wf_engine.eng_completed||':'||'CANCELED';
	   END IF;

	   -- added by syao
	   -- set notification party based on the notification type
	   pa_report_workflow_client.set_report_notification_party
	     (itemtype,
	      itemkey,
	      l_status,
	      actid,
	      funcmode,
	      l_ret
	      );


	END ;


	PROCEDURE change_status_working
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_version_id NUMBER := 0;
	     l_status VARCHAR2(30);
	     l_record_version_number NUMBER;


	     l_return_status VARCHAR2(200);
	     l_msg_data VARCHAR2(200);
	     l_msg_count number;


	BEGIN

           l_version_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'VERSION_ID');

	    l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

	    pa_progress_report_pub.rework_report
	      (
	       p_validate_only=> 'F',
	       p_commit=>'T',

	       p_version_id => l_version_id,
	       p_record_version_number=>l_record_version_number,

	       x_return_status=> l_return_status,
	       x_msg_count=>l_msg_count,
	       x_msg_data=> l_msg_data

	       );

	END ;


	PROCEDURE change_status_rejected
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_version_id NUMBER := 0;
	     l_status VARCHAR2(30);
	     l_record_version_number NUMBER;

	     l_return_status VARCHAR2(200);
	     l_msg_data VARCHAR2(200);
	     l_msg_count number;
	     l_comment VARCHAR2(2000);
	     l_name VARCHAR2(200);

	BEGIN

           l_version_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'VERSION_ID');

	    l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

	    pa_progress_report_pub.reject_report
	      (
	       p_validate_only=> 'F',
	       p_commit=>'T',

	       p_version_id => l_version_id,
	       p_record_version_number=>l_record_version_number,

	       x_return_status=> l_return_status,
	       x_msg_count=>l_msg_count,
	       x_msg_data=> l_msg_data

	       );

	    IF (l_return_status = 'S' ) THEN
	       l_comment     := wf_engine.GetItemAttrText
		 ( itemtype       => itemtype,
		   itemkey        => itemkey,
		   aname          => 'COMMENT');

	       l_name :=  wf_engine.GetItemAttrText(  itemtype
						      , itemkey
						      , 'REPORT_APPROVER_USER_NAME');

	       pa_workflow_history.save_comment_history (
							 itemtype
							 ,itemkey
							 ,'REJECT'
							 ,l_name ,
							 l_comment);

	       check_progress_status
		 (itemtype
		  ,itemkey
		  ,actid
		  ,funcmode
		  ,resultout                   );


	    END IF;


	END ;


	PROCEDURE change_status_approved
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

             l_version_id NUMBER := 0;
	     l_status VARCHAR2(30);
	     l_record_version_number NUMBER;
         --  l_summary_version_number NUMBER; --Commented for Bug 3629793

	     l_return_status VARCHAR2(200);
	     l_msg_data VARCHAR2(200);
	     l_msg_count number;

	     l_dummy VARCHAR2(1);
	     l_auto_approved VARCHAR2(10);

	     CURSOR is_auto_published IS
		SELECT 'Y'
		  FROM dual
		  WHERE exists
		  (SELECT * FROM pa_progress_report_vers pprv, pa_object_page_layouts popl
		   WHERE pprv.version_id = l_version_id
		   AND pprv.object_id = popl.object_id
		   AND pprv.object_type = popl.object_type
		   AND popl.approval_required = 'A');

	      l_comment VARCHAR2(2000);
	      l_name VARCHAR2(200);

	BEGIN

           l_version_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'VERSION_ID');

	    l_record_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'RECORD_VERSION_NUMBER');

	     /* Commented for Bug 3629793
	     l_summary_version_number     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'SUMMARY_VERSION_NUMBER');
	      */

	    -- if autopublish, we will publish the report directly
	    --OPEN is_auto_published;
	    --FETCH is_auto_published INTO l_dummy;
	    --CLOSE is_auto_published;

	     -- we get the autopublish info from item attribute now

	     l_auto_approved     := wf_engine.GetItemAttrText
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'AUTO_APPROVED');

	     --	    IF l_dummy = 'Y' THEN
	     --debug_msg ('Workflow ended before autopublish ' || l_auto_approved);


	     IF l_auto_approved = 'A' then
	       pa_progress_report_pub.publish_report
		 (
		  p_validate_only=> 'F',
		  p_commit=>'T',

		  p_version_id => l_version_id,
		  p_record_version_number=>l_record_version_number,
            --    p_summary_version_number=>l_summary_version_number, -- Commented for Bug 3629793

		  x_return_status=> l_return_status,
		  x_msg_count=>l_msg_count,
		  x_msg_data=> l_msg_data

		  );
	     ELSE

	       pa_progress_report_pub.approve_report
		 (
		  p_validate_only=> 'F',
		  p_commit=>'T',

		  p_version_id => l_version_id,
		  p_record_version_number=>l_record_version_number,

		  x_return_status=> l_return_status,
		  x_msg_count=>l_msg_count,
		  x_msg_data=> l_msg_data

		  );
	     END IF;

	     IF (l_return_status = 'S') THEN


	       l_comment     := wf_engine.GetItemAttrText
		 ( itemtype       => itemtype,
		   itemkey        => itemkey,
		   aname          => 'COMMENT');

	       l_name :=  wf_engine.GetItemAttrText(  itemtype
						      , itemkey
						      , 'REPORT_APPROVER_USER_NAME');

	       pa_workflow_history.save_comment_history (
							 itemtype
							 ,itemkey
							 ,'APPROVE'
							 ,l_name ,
							 l_comment);

	       -- need to reset the notification party for the APPROVED
	       -- message
	       check_progress_status
		 (itemtype
		  ,itemkey
		  ,actid
		  ,funcmode
		  ,resultout                   );

	     END IF;



	END ;


	PROCEDURE is_submitter_same_as_reporter
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
          IS

	     --reported_by is person_id
	     l_reported_by_id NUMBER;
	     l_submitter_id NUMBER;
	     l_submitter_emp_id NUMBER;
	     --l_reported_emp_id NUMBER;

	     CURSOR get_submitter_emp_id IS
		SELECT  employee_id
		  FROM    fnd_user
		  WHERE   user_id = l_submitter_id;


	     CURSOR get_reporter_emp_id IS
		SELECT  employee_id
		  FROM    fnd_user
		  WHERE   user_id = l_reported_by_id;


	BEGIN

	    l_reported_by_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'REPORTED_BY_ID');

	    l_submitter_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => itemtype,
                 itemkey        => itemkey,
                 aname          => 'SUBMITTER_ID');

	    --OPEN get_reporter_emp_id;
	    --FETCH get_reporter_emp_id INTO l_reported_emp_id;
	    --CLOSE get_reporter_emp_id;

	    OPEN get_submitter_emp_id;
	    FETCH get_submitter_emp_id INTO l_submitter_emp_id;
	    CLOSE get_submitter_emp_id;

	    IF l_submitter_emp_id = l_reported_by_id THEN

	       resultout := wf_engine.eng_completed||':'||'T';
	     ELSE

	       resultout := wf_engine.eng_completed||':'||'F';
	    END IF;

	    --debug_msg('is_submitter_same_as_reporter ');
	    --debug_msg('returning ' || resultout);

	    --debug_msg('l_submitter_emp_id ' || To_char(l_submitter_emp_id));
	    --debug_msg('l_reporter_emp_id ' || To_char(l_reported_by_id));


	END;

	 Procedure  start_action_set_workflow
	 (
	    p_item_type         IN     VARCHAR2
	  , p_process_name      IN     VARCHAR2

	  , p_object_type       IN     VARCHAR2
	  , p_object_id         IN     NUMBER

	  ,p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
	  ,p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type

	  ,x_action_line_audit_tbl  out NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type  --File.Sql.39 bug 4440895
	  , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
          , x_msg_data       out      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )
        IS

	   l_item_key VARCHAR2(200);
	   l_last_item_key VARCHAR2(200);
	   l_err_code NUMBER;
	   l_err_stage VARCHAR2(30);
	   l_err_stack VARCHAR2(240);
	   l_customer  VARCHAR2(4000);
	   l_project_manager  VARCHAR2(240);
	   l_project VARCHAR2(500);
	   l_org  pa_project_lists_v.carrying_out_organization_name%TYPE; -- Bug 4358517.
	   l_report_type_name VARCHAR2(80);
	   l_url2     VARCHAR2(600);
	   l_project_id NUMBER;
	   l_report_start_date DATE;
	   l_report_end_date DATE;
	   l_Report_Type_Id             NUMBER := null;
	   l_Reporting_Cycle_Id		NUMBER := null;
	   l_Reporting_Offset_Days	NUMBER := null;
	   l_effective_from DATE;



	   CURSOR get_last_workflow_info
	     IS
		SELECT MAX(item_key)
		  FROM pa_wf_processes
		  WHERE item_type = p_item_type
		  AND description = p_process_name
		  AND entity_key1 = l_project_id
		  AND wf_type_code = 'Progress Report'
		  ;


	   CURSOR get_project_info IS
	      SELECT
		pplv. customer_name,
		 pplv.person_name,
		 pplv.carrying_out_organization_name,
		 pplv.name || '(' || pplv.segment1 || ')',
		prt.name,
		pplv.project_id
		FROM pa_project_lists_v pplv, pa_object_page_layouts popl, pa_report_types prt
		 WHERE pplv.project_id = popl.object_id
		AND popl.object_page_layout_id = p_object_id
		AND popl.object_type = 'PA_PROJECTS'
		and nvl(popl.report_type_id, 1) = prt.report_type_id
		;

	   CURSOR get_object_page_info IS
	      SELECT
		report_type_id,
		reporting_cycle_id,
		report_offset_days,
		effective_from
		FROM pa_object_page_layouts
		WHERE
		object_page_layout_id = p_object_id
		and
		page_type_code = 'PPR';


        BEGIN

	   --debug_msg_s1 ('start workflow 1: starting');

	   SELECT To_char(pa_workflow_itemkey_s.NEXTVAL)
	     INTO l_item_key
	     from dual;


	   x_return_status := FND_API.G_RET_STS_SUCCESS;


	   -- create the workflow process

	   --debug_msg_s1 ('start workflow 1: starting');
	   WF_ENGINE.CreateProcess(    p_item_type
				     , l_item_key
				       , p_Process_Name);

	   --debug_msg_s1 ('start workflow 1: starting 2');

	   wf_engine.SetItemAttrNumber( p_item_type
                                      , l_item_key
                                      , 'OBJECT_ID'
                                      ,p_object_id
				      );

	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'OBJECT_TYPE'
                                      ,p_object_type
				      );


	   -- set some of the common item attributes
	   OPEN get_project_info;
	   FETCH get_project_info INTO l_customer,l_project_manager, l_org, l_project, l_report_type_name, l_project_id;

	   --debug_msg_s ('mgr ' || l_project_manager);

	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'PROJECT_MANAGER'
                                      ,l_project_manager
				      );
	   CLOSE get_project_info;

	   --debug_msg_s ('org ' || l_org);
	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'ORGANIZATION'
                                      ,l_org
				      );
	   --debug_msg_s ('customer ' || l_customer);
	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'CUSTOMER'
                                      ,l_customer
				      );

	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'PROJECT'
                                      ,l_project
				      );

	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'REPORT_TYPE'
                                      ,l_report_type_name
				      );

	   OPEN get_object_page_info;
	   FETCH get_object_page_info INTO l_report_type_id, l_reporting_cycle_id,
	     l_reporting_offset_days, l_effective_from;
	   CLOSE get_object_page_info;


	   l_url2 := 'JSP:/OA_HTML/OA.jsp?paProjectId='||  l_project_id||
	     '&akRegionCode=PA_PROG_RPT_MAINT_LAYOUT&akRegionApplicationId=275&paPageMode=APPROVE&addBreadCrumb=RP&paProgressMode=MAINTENANCE&paReportTypeId='
	     || l_Report_Type_Id;

	   wf_engine.SetItemAttrText( p_item_type
                                      , l_item_key
                                      , 'REPORT_LINK'
                                      , l_url2
				      );




	   --debug_msg_s1 ('Parameter ' || l_project_id);
	   --debug_msg_s1 ('Parameter ' || l_Report_Type_Id);
	   --debug_msg_s1 ('Parameter ' || l_Reporting_Cycle_Id);
	   --debug_msg_s1 ('Parameter ' || l_Reporting_Offset_Days);


	   IF l_reporting_cycle_id IS NOT NULL THEN
	   pa_progress_report_utils.Get_Report_Start_End_Dates(
				   p_object_type=>'PA_PROJECTS',
				   p_object_id=>l_project_id,
				   p_report_type_id=>l_Report_Type_Id     ,
				   p_reporting_cycle_id=>l_Reporting_Cycle_Id   ,
				   p_reporting_offset_days=>l_Reporting_Offset_Days  ,
							       p_publish_report=>       'Y',
							       p_report_effective_from => l_effective_from,
							x_report_start_date=>       l_report_start_date,
							    x_report_end_date=>   l_report_end_date
							       );
	    ELSE
	      l_report_start_date :=  Trunc(Sysdate);
	      l_report_end_date :=  Trunc(Sysdate);

	   END IF;

	   -- set report start date
	   wf_engine.SetItemAttrDate( p_item_type
                                      , l_item_key
                                      , 'REPORT_START_DATE'
                                      ,l_report_start_date
				      );

	   -- set report start date
	   wf_engine.SetItemAttrDate( p_item_type
                                      , l_item_key
                                      , 'REPORT_END_DATE'
                                      ,l_report_end_date
				      );

	   -- cancel the last running workflow process on the same item_type,
	   -- process name
	   -- this is required for todo workflow because the last one always
	   -- override the previous workflow process

	   -- get the last workflow info

	   --debug_msg_s1 ('start workflow 1');


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


	   CLOSE get_last_workflow_info;      -- Bug #3905748

	   --debug_msg_s1 ('after workflow 1' ||p_process_name );

	   -- set notification party

	   IF p_process_name = 'PA_PROJ_STATUS_REPORT_NEXT' THEN
	      -- reminder workflow process
	      set_reminder_report_notify(p_item_type,
					 l_item_key,
					 p_object_type,
					 p_object_id,
					 p_action_set_line_rec,
					 p_action_line_conditions_tbl,
					 x_action_line_audit_tbl);
	    ELSIF p_process_name = 'PA_PROJ_STATUS_REPORT_MISS' THEN
	      -- missing report workflow process
	       set_missing_report_notify(p_item_type,
					 l_item_key,
					 p_object_type,
					 p_object_id,
					 p_action_set_line_rec,
					 p_action_line_conditions_tbl,
					 x_action_line_audit_tbl);

	   END IF;


	   -- ready to start the workflow

	   --debug_msg_s1 ('after workflow 1' || x_return_status);
	   IF x_return_status = FND_API.g_ret_sts_success then


	      --debug_msg_s1 ('after workflow 1: start process');

	      WF_ENGINE.StartProcess(
				     p_Item_Type
				     , l_Item_Key
				     );
	   END IF;

	   -- added for creating record in the audit table

	   -- insert into pa_wf_process table

	   --debug_msg_s1 ('after workflow 1: isnertwf processes' || p_item_type);
	   --debug_msg_s1 ('after workflow 1: isnertwf processes' || l_item_key);



	   PA_WORKFLOW_UTILS.Insert_WF_Processes
                      (p_wf_type_code           => 'Progress Report'
                       ,p_item_type              => p_item_type
                       ,p_item_key               => l_item_key
                       ,p_entity_key1            => p_object_id
                       ,p_entity_key2            => l_project_id
                       ,p_description            => p_process_name
                       ,p_err_code               => l_err_code
                       ,p_err_stage              => l_err_stage
                       ,p_err_stack              => l_err_stack
                       );
	   --debug_msg_s1 ('after workflow 1: isnertwf processes' || l_err_code);

	   IF l_err_code <> 0 THEN
	      PA_UTILS.Add_Message( p_app_short_name => 'PA'
				    ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
				    x_return_status := FND_API.G_RET_STS_ERROR;

				    END IF;


	   --debug_msg_s1 ('after workflow 1: isnertwf processes: returns');

	   COMMIT;

        EXCEPTION

	   WHEN OTHERS THEN

	      --debug_msg_s1 ('after workflow 1: exception' || substr(SQLERRM,1,2000));
	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	      RAISE;

        END start_action_set_workflow;




	PROCEDURE set_reminder_report_notify(  p_item_type         IN     VARCHAR2
					     , p_item_key          IN     NUMBER
					     , p_object_type       IN     VARCHAR2
					     , p_object_id         IN     NUMBER

					     , p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
					     , p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type

					     , x_action_line_audit_tbl  out NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type 			 --File.Sql.39 bug 4440895
						)

	  IS

	     l_object_type VARCHAR2(30);
	     l_object_id NUMBER;
	     l_project_id NUMBER;
	     l_next_reporting_date DATE;
	     l_reminder_days NUMBER;
	     l_action_set_id NUMBER;
	     l_project_name VARCHAR2(30);
	     l_project_number  VARCHAR2(25);
	     l_action_code VARCHAR2(30);
	     l_reminder_role varchar2(30) := NULL;
	     l_reminder_role_display_name varchar2(30) := NULL; -- Bug 4565156.
	     l_role_users    varchar2(30000) := NULL;

	     l_days NUMBER;

	     l_INDEX NUMBER;

	     CURSOR get_obj_page_layout_info
	       IS
		  SELECT object_id, reminder_days, next_reporting_date
		    FROM pa_object_page_layouts
		    WHERE object_page_layout_id = l_object_id
		    AND object_type = 'PA_PROJECTS';


	     CURSOR get_person_name(l_user_name varchar2)
	       IS
		    SELECT papf.full_name person_name,
		      papf.email_address
		      FROM
		      fnd_user fu,per_all_people_f papf
		      where  fu.employee_id = papf.person_id
		      AND fu.user_name = l_user_name
		      AND   trunc(sysdate) between papf.EFFECTIVE_START_DATE
		      and		  Nvl(papf.effective_end_date, Sysdate + 1)
		      and    trunc(sysdate) between fu.START_DATE and nvl(fu.END_DATE, sysdate+1);

	       l_user_names         pa_distribution_list_utils.pa_vc_1000_150;
	       l_full_names         pa_distribution_list_utils.pa_vc_1000_150;
	       l_email_addresses    pa_distribution_list_utils.pa_vc_1000_150;
	       l_return_status      VARCHAR2(1);
	       l_msg_count          NUMBER;
	       l_msg_data           VARCHAR2(2000);
	       i INTEGER;

	       l_t1 VARCHAR2(30);
	       l_t2 VARCHAR2(30);
	       l_t3 VARCHAR2(300);

	       display_name VARCHAR2(2000);
	       email_address VARCHAR2(2000);
	       notification_preference VARCHAR2(2000);
	       language VARCHAR2(2000);
	       territory VARCHAR2(2000);
	BEGIN


	   l_object_id     := p_object_id;

	   l_days := To_number(p_action_line_conditions_tbl(1).condition_attribute1);

	   l_object_type     := p_object_type;

	   -- get the project info, reminder days and next reporting days
	   OPEN get_obj_page_layout_info;
	   FETCH get_obj_page_layout_info INTO l_project_id, l_reminder_days,
	     l_next_reporting_date;



	   CLOSE get_obj_page_layout_info;

	   -- get Project Name, Number info
	    pa_utils.getprojinfo(l_project_id, l_project_number, l_project_name);
	    -- set item attribute for Project Name, Number
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

	    -- set item attribute for reminder days and next reporting date
	    wf_engine.SetItemAttrDate( p_item_type
                                      , p_item_key
                                      , 'NEXT_REPORT_DATE'
                                      ,l_next_reporting_date
					);

	    wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'REMINDER_DAYS'
                                      ,l_reminder_days
					 );

	    -- set notification party
	    l_reminder_role := 'RMND_' ||p_item_type ||  p_item_key;
	    l_reminder_role_display_name := l_reminder_role; -- Bug 4565156.

	     WF_DIRECTORY.CreateAdHocRole( role_name         => l_reminder_role
                                       , role_display_name => l_reminder_role_display_name -- Bug 4565156.
					   , expiration_date   => sysdate+1); -- Set expiration_date for bug#5962401




	    l_INDEX := 1;


	    PA_DISTRIBUTION_LIST_UTILS.get_dist_list
	      (
	       l_object_type,
	       l_object_id,

	       2,  -- edit and view priv
	       l_user_names         ,
	       l_full_names         ,
	       l_email_addresses    ,
	       l_return_status      ,
	       l_msg_count          ,
	       l_msg_data
	       );

	      IF (l_return_status = 'S' AND l_user_names IS NOT null) then
	       FOR i in l_user_names.First..l_user_names.LAST LOOP

		   IF l_user_names(i) IS NULL THEN
			--EXIT ;
			l_user_names(i) := Upper(l_email_addresses(i));
			l_full_names(i) := l_email_addresses(i);

		    END IF;

		     if (l_role_users is not null) then
			l_role_users := l_role_users || ',';
			  END IF;


		 wf_directory.getroleinfo(Upper(l_user_names(i)),display_name,
  email_address,notification_preference,language,territory);
   if display_name is null THEN

		 --IF NOT wf_directory.useractive (l_user_names(i)) THEN

		    WF_DIRECTORY.CreateAdHocUser( name => l_user_names(i)
						  , display_name => l_full_names(i)
						  , EMAIL_ADDRESS =>l_email_addresses(i));
		 END IF;
		 l_role_users := l_role_users || l_user_names(i);

		 x_action_line_audit_tbl(i).reason_code                 := 'CONDITION_MET';
		 x_action_line_audit_tbl(i).action_code                 := p_action_set_line_rec.action_code;
		 x_action_line_audit_tbl(i).audit_display_attribute     := l_full_names(i);
		 x_action_line_audit_tbl(i).audit_attribute             := l_user_names(i);
		 x_action_line_audit_tbl(i).reversed_action_set_line_id := NULL;
L_INDEX := L_INDEX +1;
	      end loop;

	      END IF;




	      IF (l_role_users is NOT NULL) THEN
		  --debug_msg2('Add user role' || l_reporter_role);
	      --debug_msg_s1('Add users: ' || l_role_users);
	      WF_DIRECTORY.AddUsersToAdHocRole( l_reminder_role
						, l_role_users);


	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'REPORT_REMINDER_NAME'
					  , l_reminder_role);
	      --debug_msg ('OK: approver is found ');

	    ELSE
	      --debug_msg ('Error: no approver is found ');
	      NULL;
	   END IF;

	   --debug_msg2 ('after add users to the role ' || l_approval_role );

	   commit;



	EXCEPTION

	   WHEN OTHERS THEN
	      RAISE;

	END set_reminder_report_notify;

	PROCEDURE set_missing_report_notify
	  (  p_item_type         IN     VARCHAR2
	     , p_item_key          IN     NUMBER
	     , p_object_type       IN     VARCHAR2
	     , p_object_id         IN     NUMBER

	     , p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
	     , p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type

	     , x_action_line_audit_tbl  out NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type 			 --File.Sql.39 bug 4440895
	     )
	  	  IS

	     l_object_type VARCHAR2(30);
	     l_object_id NUMBER;
	     l_project_id NUMBER;
	     l_days NUMBER;
	     l_next_reporting_date DATE;
	     l_reminder_days NUMBER;
	     l_action_set_id NUMBER;
	     l_project_name VARCHAR2(30);
	     l_project_number  VARCHAR2(25);
	     l_object_page_layout_id NUMBER;
	     l_reminder_role varchar2(30) := NULL;
	     l_reminder_role_display_name varchar2(30) := NULL; -- Bug 4565156.
	     l_role_users    varchar2(30000) := NULL;
	     l_action_attribute1 VARCHAR2(150);
	     l_role_id VARCHAR2(30);
	     l_approver_id NUMBER;
	     l_approver_source_type NUMBER;

	     CURSOR get_obj_page_layout_info
	       IS
		  SELECT object_id, reminder_days, next_reporting_date
		    FROM pa_object_page_layouts
		    WHERE object_page_layout_id = l_object_id
		    AND object_type = 'PA_PROJECTS';

	     CURSOR l_report_approver_csr_person IS
		select distinct
		  fu.user_id,
		  fu.user_name,
		  papf.email_address,
		  papf.full_name person_name
		  from
		  fnd_user fu,per_all_people_f papf
		  where
		  fu.employee_id = l_approver_id
		  and  papf.person_id = fu.employee_id
		      and    trunc(sysdate)
		    between papf.EFFECTIVE_START_DATE
		    and		  Nvl(papf.effective_end_date, Sysdate + 1)
		  and    trunc(sysdate) between fu.START_DATE and nvl(fu.END_DATE, sysdate+1)
		  ;

	       CURSOR l_report_approver_csr_party IS
		select distinct
		  fu.user_id,
		  fu.user_name,
		  papf.email_address,
		  papf.full_name person_name
		  from
		  fnd_user fu,per_all_people_f papf
		  where
		  fu.person_party_id = l_approver_id -- Bug 4527617. Replaced customer_id with person_party_id.
		  and  papf.person_id = fu.employee_id
		      and    trunc(sysdate)
		    between papf.EFFECTIVE_START_DATE
		    and		  Nvl(papf.effective_end_date, Sysdate + 1)
		  and    trunc(sysdate) between fu.START_DATE and nvl(fu.END_DATE, sysdate+1)
		  ;

	     CURSOR l_missing_csr IS
		select distinct
		  fu.user_id,
		  fu.user_name,
		  papf.email_address,
		  papf.full_name person_name,
          ppp.resource_source_id
		  from
		  pa_project_parties ppp,
		  fnd_user fu,per_all_people_f papf
		  where  ppp.project_id  = l_project_id
		  and ppp.project_role_id = To_number(l_role_id)
		  and ppp.project_id = ppp.object_id
		  AND fu.employee_id = ppp.resource_source_id
		  and  papf.person_id = fu.employee_id
		      and    trunc(sysdate)
		    between papf.EFFECTIVE_START_DATE
		    and		  Nvl(papf.effective_end_date, Sysdate + 1)
		  and    trunc(sysdate) between fu.START_DATE and nvl(fu.END_DATE, sysdate+1)
          and    trunc(sysdate) between ppp.START_DATE_active
		  and nvl(ppp.END_DATE_active, sysdate+1);

	/* Bug 2911451 Included checks primary_flag='Y' and Assignment_type ='E'
	   for the project manager ie p1.person_id
	   Also included checks primary_flag='Y' and Assignment_type ='E' and date check
	   for the Supervisor of this person  */
	       CURSOR l_hr_manager_csr IS
		  select distinct
		  fu.user_id,
		  fu.user_name,
		  p2.email_address,
		  p2.full_name person_name
		  from
		  pa_proj_parties_prog_ev_v ppp,
		  fnd_user fu,per_all_people_f p2,
		    per_assignments_f p1
		    where  ppp.project_id  = l_project_id
		    and ppp.project_role_id = 1
		    and ppp.resource_source_id = p1.person_id
		    and p1.primary_flag='Y'
                    and p1.Assignment_type in ('E', 'C')
		    and p1.supervisor_id = p2.person_id
		    and  p1.supervisor_id = fu.employee_id
		    and    trunc(sysdate)
		    between p1.EFFECTIVE_START_DATE
		    and		  p1.effective_end_date  -- Removed nvl for bug 2911451
		    and    trunc(sysdate) between fu.START_DATE and nvl(fu.END_DATE, sysdate+1)
		      and    trunc(sysdate) between ppp.START_DATE_active
		  and nvl(ppp.END_DATE_active, sysdate+1)
		  and exists ( select 1 from per_assignments_f p3
		               where p3.person_id = p1.supervisor_id
			       and p3.primary_flag='Y'
                               and p3.Assignment_type in ('E', 'C')
			       and trunc(sysdate) between p3.EFFECTIVE_START_DATE and Nvl(p3.effective_end_date, Sysdate + 1));

	     CURSOR get_action_attribute
	       IS
		  SELECT action_attribute1
		    FROM pa_action_set_lines
		    WHERE action_set_line_id = l_action_set_id;

	     CURSOR get_approver_source_id
	       IS
		  SELECT approver_source_id, approver_source_type
		    FROM pa_progress_report_setup_v
		    WHERE object_page_layout_id = l_object_page_layout_id;


	     L_INDEX NUMBER;

	     l_user_names         pa_distribution_list_utils.pa_vc_1000_150;
	     l_full_names         pa_distribution_list_utils.pa_vc_1000_150;
	     l_email_addresses    pa_distribution_list_utils.pa_vc_1000_150;
	     l_return_status      VARCHAR2(1);
	     l_msg_count          NUMBER;
	     l_msg_data           VARCHAR2(2000);
	     i INTEGER;


	     l_t1 VARCHAR2(30);
	     l_t2 VARCHAR2(30);
	     l_t3 VARCHAR2(300);
	     l_find_duplicate VARCHAR2(1) := 'N';
	     display_name VARCHAR2(2000);
	     email_address VARCHAR2(2000);
	     notification_preference VARCHAR2(2000);
	     language VARCHAR2(2000);
	     territory VARCHAR2(2000);

	BEGIN

	   l_object_id     := p_object_id;
	   l_object_type     := p_object_type;

	   l_days := To_number(p_action_line_conditions_tbl(1).condition_attribute1);
	   l_role_id := p_action_set_line_rec.action_attribute1;

	   l_object_page_layout_id := l_object_id;

	   -- get the project info, reminder days and next reporting days
	   OPEN get_obj_page_layout_info;
	   FETCH get_obj_page_layout_info INTO l_project_id, l_reminder_days,
	     l_next_reporting_date;

	   CLOSE get_obj_page_layout_info;

	   -- get Project Name, Number info
	    pa_utils.getprojinfo(l_project_id, l_project_number, l_project_name);
	    -- set item attribute for Project Name, Number
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

	    -- set item attribute for reminder days and next reporting date
	    wf_engine.SetItemAttrDate( p_item_type
                                      , p_item_key
                                      , 'NEXT_REPORT_DATE'
                                      ,l_next_reporting_date
					);

	    wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'REMINDER_DAYS'
                                      ,l_reminder_days
					 );

	    -- set notification party
	    l_reminder_role := 'MRMND_' ||p_item_type ||  p_item_key;
	    l_reminder_role_display_name := l_reminder_role; -- Bug 4565156.
	    WF_DIRECTORY.CreateAdHocRole( role_name         => l_reminder_role
                                       , role_display_name => l_reminder_role_display_name -- Bug 4565156.
					  , expiration_date   => sysdate+1); -- Set expiration_date for bug#5962401




	    /* add people with edit privilege first */
	    l_INDEX := 1;


	     PA_DISTRIBUTION_LIST_UTILS.get_dist_list
	       (

	       l_object_type,
	       l_object_id,
	       2,  -- edit and view priv
	       l_user_names         ,
	       l_full_names         ,
	       l_email_addresses    ,
	       l_return_status      ,
	       l_msg_count          ,
	       l_msg_data
	       );

	      IF (l_return_status = 'S' AND l_user_names IS NOT null) then
	       FOR i in l_user_names.First..l_user_names.LAST LOOP

		   IF l_user_names(i) IS NULL THEN
			--EXIT ;
			l_user_names(i) := Upper(l_email_addresses(i));
			l_full_names(i) := l_email_addresses(i);

		    END IF;

		     if (l_role_users is not null) then
		    l_role_users := l_role_users || ',';
		     END IF;


		 wf_directory.getroleinfo(Upper(l_user_names(i)),display_name,
					  email_address,notification_preference,language,territory);
		 if display_name is null THEN

		 --IF NOT wf_directory.useractive (l_user_names(i)) THEN

		    WF_DIRECTORY.CreateAdHocUser( name => l_user_names(i)
						  , display_name => l_full_names(i)
						  , EMAIL_ADDRESS =>l_email_addresses(i));
		 END IF;
		 l_role_users := l_role_users || l_user_names(i);

		 x_action_line_audit_tbl(i).reason_code                 := 'CONDITION_MET';
		 x_action_line_audit_tbl(i).action_code                 := p_action_set_line_rec.action_code;
		 x_action_line_audit_tbl(i).audit_display_attribute     := l_full_names(i);
		 x_action_line_audit_tbl(i).audit_attribute             := l_user_names(i);
		 x_action_line_audit_tbl(i).reversed_action_set_line_id := NULL;
		 L_INDEX := L_INDEX +1;

	      end loop;

	      END IF;


	    IF l_role_id = '-1' THEN
        	-- HR Manager of Project Manager
	        -- Approver of the project status report setup
	       for v_reminders in l_hr_manager_csr loop

		  --debug_msg2 ('add user name: ' || v_approvers.user_name);
		  --debug_msg2 ('add user id: ' || v_approvers.person_name);
		  --debug_msg2 ('add user id: ' || v_approvers.email_address);

		  l_find_duplicate := 'N';

		  IF (Instr(l_role_users, v_reminders.user_name||',') = 1) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name||',') >0) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name) = (Length(l_role_users)  - Length(v_reminders.user_name))) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';

		  END IF;



		  IF l_find_duplicate = 'N' THEN

		  if (l_role_users is not null) then
		     l_role_users := l_role_users || ',';
		  end if;

		  -- Create adhoc users
		    wf_directory.getroleinfo(Upper(v_reminders.user_name),display_name,
  email_address,notification_preference,language,territory);
		  if display_name is null THEN
		  --IF NOT wf_directory.useractive (v_reminders.user_name) THEN

		    --debug_msg('Add user');

		    WF_DIRECTORY.CreateAdHocUser( name => v_reminders.user_name
						  , display_name => v_reminders.person_name
						  --, notification_preference => 'MAILTEXT'
						  , EMAIL_ADDRESS =>v_reminders.email_address);
		  END IF;
		  l_role_users := l_role_users || v_reminders.user_name;
 x_action_line_audit_tbl(l_index).reason_code                 := 'CONDITION_MET';
		 x_action_line_audit_tbl(l_index).action_code                 := p_action_set_line_rec.action_code;
		 x_action_line_audit_tbl(l_index).audit_display_attribute     := v_reminders.person_name;
		 x_action_line_audit_tbl(l_index).audit_attribute             := v_reminders.user_name;
		 x_action_line_audit_tbl(l_index).reversed_action_set_line_id := NULL;
		 L_INDEX := L_INDEX +1 ;
		  END IF;

	       end loop;

	     ELSIF l_role_id = '-2' THEN
	       -- Approver of the project status report setup

	       OPEN get_approver_source_id;
	       FETCH get_approver_source_id INTO l_approver_id, l_approver_source_type;

	       IF get_approver_source_id%found AND l_approver_id IS NOT NULL then
		  --IF approver is not null, we will use the ID to get the people
		  CLOSE get_approver_source_id;

		  IF l_approver_source_type = 101 THEN
		     -- source type is person
		     for v_reminders in l_report_approver_csr_person loop

			--debug_msg2 ('add user name: ' || v_approvers.user_name);
			--debug_msg2 ('add user id: ' || v_approvers.person_name);
			--debug_msg2 ('add user id: ' || v_approvers.email_address);
			  l_find_duplicate := 'N';

		  IF (Instr(l_role_users, v_reminders.user_name||',') = 1) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name||',') >0) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name) = (Length(l_role_users)  - Length(v_reminders.user_name))) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';

		  END IF;



		  IF l_find_duplicate = 'N' THEN


			if (l_role_users is not null) then
			   l_role_users := l_role_users || ',';
			end if;

			-- Create adhoc users

			  wf_directory.getroleinfo(Upper(v_reminders.user_name),display_name,
  email_address,notification_preference,language,territory);
		  if display_name is null THEN
			--IF NOT wf_directory.useractive (v_reminders.user_name) THEN
			   --debug_msg('Add user');

			   WF_DIRECTORY.CreateAdHocUser( name => v_reminders.user_name
							 , display_name => v_reminders.person_name
							 --, notification_preference => 'MAILTEXT'
							 , EMAIL_ADDRESS =>v_reminders.email_address);
			END IF;

			l_role_users := l_role_users || v_reminders.user_name;

			x_action_line_audit_tbl(l_index).reason_code                 := 'CONDITION_MET';
			x_action_line_audit_tbl(l_index).action_code                 := p_action_set_line_rec.action_code;
			x_action_line_audit_tbl(l_index).audit_display_attribute     := v_reminders.person_name;
			x_action_line_audit_tbl(l_index).audit_attribute             := v_reminders.user_name;
			x_action_line_audit_tbl(l_index).reversed_action_set_line_id := NULL;
			L_INDEX := L_INDEX +1 ;
		  END IF;

		     end loop;
		   ELSIF l_approver_source_type = 112 THEN
		     -- source type is party
		     for v_reminders in l_report_approver_csr_party loop

			--debug_msg2 ('add user name: ' || v_approvers.user_name);
			--debug_msg2 ('add user id: ' || v_approvers.person_name);
			--debug_msg2 ('add user id: ' || v_approvers.email_address);

			  l_find_duplicate := 'N';

		  IF (Instr(l_role_users, v_reminders.user_name||',') = 1) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name||',') >0) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name) = (Length(l_role_users)  - Length(v_reminders.user_name))) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';

		  END IF;



		  IF l_find_duplicate = 'N' THEN

			if (l_role_users is not null) then
			   l_role_users := l_role_users || ',';
			end if;

			-- Create adhoc users
			 wf_directory.getroleinfo(Upper(v_reminders.user_name),display_name,
  email_address,notification_preference,language,territory);
		  if display_name is null THEN
			--IF NOT wf_directory.useractive (v_reminders.user_name) THEN
			   --debug_msg('Add user');

			   WF_DIRECTORY.CreateAdHocUser( name => v_reminders.user_name
							 , display_name => v_reminders.person_name
							 --, notification_preference => 'MAILTEXT'
							 , EMAIL_ADDRESS =>v_reminders.email_address);
			END IF;

			l_role_users := l_role_users || v_reminders.user_name;

			x_action_line_audit_tbl(l_index).reason_code                 := 'CONDITION_MET';
			x_action_line_audit_tbl(l_index).action_code                 := p_action_set_line_rec.action_code;
			x_action_line_audit_tbl(l_index).audit_display_attribute     := v_reminders.person_name;
			x_action_line_audit_tbl(l_index).audit_attribute             := v_reminders.user_name;
			x_action_line_audit_tbl(l_index).reversed_action_set_line_id := NULL;
			L_INDEX := L_INDEX +1 ;
		  END IF;

		     end loop;
		  END IF;

		ELSE
		  -- approver id = null else we use the HR manager
		  CLOSE get_approver_source_id;

		  -- HR Manager of Project Manager
		  -- Approver of the project status report setup
		  for v_reminders in l_hr_manager_csr loop

		     --debug_msg2 ('add user name: ' || v_approvers.user_name);
		     --debug_msg2 ('add user id: ' || v_approvers.person_name);
		     --debug_msg2 ('add user id: ' || v_approvers.email_address);

		       l_find_duplicate := 'N';

		  IF (Instr(l_role_users, v_reminders.user_name||',') = 1) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name||',') >0) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name) = (Length(l_role_users)  - Length(v_reminders.user_name))) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';

		  END IF;



		  IF l_find_duplicate = 'N' THEN

		     if (l_role_users is not null) then
			l_role_users := l_role_users || ',';
		     end if;

		     -- Create adhoc users
		      wf_directory.getroleinfo(Upper(v_reminders.user_name),display_name,
  email_address,notification_preference,language,territory);
		  if display_name is null THEN
		     --IF NOT wf_directory.useractive (v_reminders.user_name) THEN

			--debug_msg('Add user');

			WF_DIRECTORY.CreateAdHocUser( name => v_reminders.user_name
						      , display_name => v_reminders.person_name
						      --, notification_preference => 'MAILTEXT'
						      , EMAIL_ADDRESS =>v_reminders.email_address);
		     END IF;
		     l_role_users := l_role_users || v_reminders.user_name;
		     x_action_line_audit_tbl(l_index).reason_code                 := 'CONDITION_MET';
		     x_action_line_audit_tbl(l_index).action_code                 := p_action_set_line_rec.action_code;
		     x_action_line_audit_tbl(l_index).audit_display_attribute     := v_reminders.person_name;
		     x_action_line_audit_tbl(l_index).audit_attribute             := v_reminders.user_name;
		     x_action_line_audit_tbl(l_index).reversed_action_set_line_id := NULL;
		     L_INDEX := L_INDEX +1 ;
		  END IF;

		  end loop;
	       END IF;
	     ELSE
	       -- the role id is passed in
	       for v_reminders in l_missing_csr loop

		  --debug_msg2 ('add user name: ' || v_approvers.user_name);
		  --debug_msg2 ('add user id: ' || v_approvers.person_name);
		  --debug_msg2 ('add user id: ' || v_approvers.email_address);

		    l_find_duplicate := 'N';

		  IF (Instr(l_role_users, v_reminders.user_name||',') = 1) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name||',') >0) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';
		   ELSIF (Instr(l_role_users, ','||v_reminders.user_name) = (Length(l_role_users)  - Length(v_reminders.user_name))) THEN
		     -- find duplicate
		     l_find_duplicate := 'Y';

		  END IF;



		  IF l_find_duplicate = 'N' THEN

		  if (l_role_users is not null) then
		     l_role_users := l_role_users || ',';
		  end if;

		  -- Create adhoc users
		  wf_directory.getroleinfo(Upper(v_reminders.user_name),display_name,
					   email_address,notification_preference,language,territory);
		  if display_name is null THEN
		  --IF NOT wf_directory.useractive (v_reminders.user_name) THEN

		    --debug_msg('Add user');

		    WF_DIRECTORY.CreateAdHocUser( name => v_reminders.user_name
						  , display_name => v_reminders.person_name
						  , EMAIL_ADDRESS =>v_reminders.email_address);
		  END IF;
		  l_role_users := l_role_users || v_reminders.user_name;
		  x_action_line_audit_tbl(l_index).reason_code                 := 'CONDITION_MET';
		  x_action_line_audit_tbl(l_index).action_code                 := p_action_set_line_rec.action_code;
		  x_action_line_audit_tbl(l_index).audit_display_attribute     := v_reminders.person_name;
		  x_action_line_audit_tbl(l_index).audit_attribute             := v_reminders.user_name;
		  x_action_line_audit_tbl(l_index).reversed_action_set_line_id := NULL;
		  L_INDEX := L_INDEX +1 ;
		  END IF;

	       end loop;

	    END IF;



	    IF (l_role_users is NOT NULL) THEN
	        --debug_msg2('Add user role' || l_reporter_role);
		 --debug_msg2('Add users' || l_reporter_role_users);
	      WF_DIRECTORY.AddUsersToAdHocRole( l_reminder_role
						, l_role_users);


	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'REPORT_REMINDER_NAME'
					  , l_reminder_role);

	    ELSE
	      NULL;
	   END IF;

	   --debug_msg2 ('after add users to the role ' || l_approval_role );

	   commit;



	EXCEPTION

	   WHEN OTHERS THEN
	      RAISE;

	END set_missing_report_notify;


	 PROCEDURE forward_notification(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

		  IS

		      l_comment VARCHAR2(2000);
		      l_forward_to VARCHAR2(200);
		      l_forward_to_name VARCHAR2(200);
		      l_name VARCHAR2(200);
		      l_user_id NUMBER;

		      l_error_msg VARCHAR2(2000);


		      CURSOR is_user_valid
			IS
			   SELECT user_id FROM
			     fnd_user
			     WHERE user_name = l_forward_to
           and trunc(sysdate) between start_date and nvl(end_date, sysdate); /* Bug#3848024  */


		      CURSOR get_name
			IS
			 --    select party_name from
		    --(
		     select hp.party_name
		     from fnd_user fu,
		     hz_parties hp
		     where fu.user_name = l_forward_to --fnd_global.user_id
		     and fu.employee_id is null
		     and fu.person_party_id = hp.party_id -- Bug 4527617. Replaced customer_id with person_party_id.
		     union
		     select hp.party_name
		     from fnd_user fu,
		     hz_parties hp
		     where fu.user_name = l_forward_to--fnd_global.user_id
		     and fu.employee_id is not null
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
			aname          => 'FORWARD_TO_USERNAME_RESPONSE'); -- Changed 'FORWARD_TO' to 'FORWARD_TO_USERNAME_RESPONSE' for bug 4165780

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
		         wf_directory.getroleinfo(Upper(l_forward_to),display_name,
  email_address,notification_preference,language,territory);
		  if display_name is null THEN
		       --IF NOT wf_directory.useractive (l_forward_to) THEN

			  --debug_msg('Add user');

			  WF_DIRECTORY.CreateAdHocUser( name => l_forward_to
							, display_name => l_forward_to
							--, notification_preference => 'MAILTEXT'
							, EMAIL_ADDRESS =>'');
		       END IF;

		       --debug_msg_s1 ('forward AAAAAAAAAAA  get approval comment: forward to = ' || l_forward_to);

		       wf_engine.SetItemAttrText(  itemtype
						   , itemkey
							 , 'REPORT_APPROVER_NAME'
						   , l_forward_to);


		       OPEN get_name ;
		       FETCH get_name INTO l_forward_to_name;
			 CLOSE get_name;


                        /* Start of Addition for bug 5027098 */

                               l_name :=  wf_engine.GetItemAttrText(  itemtype
                                                                    , itemkey
                                                                    , 'REPORT_APPROVER_USER_NAME');
                                wf_engine.SetItemAttrText ( itemtype,
                                                            itemkey,
                                                            'FROM_ROLE_VALUE',
                                                            l_name);
                        /* End of Addition for bug 5027098 */

			 l_name :=  wf_engine.GetItemAttrText(  itemtype
								, itemkey
								, 'REPORT_APPROVER_FULL_NAME');


			wf_engine.SetItemAttrText(  itemtype
						   , itemkey
							 , 'REPORT_APPROVER_USER_NAME'
						   , l_forward_to);

			 /* Start of Addition for bug 4165780*/
			 wf_engine.SetItemAttrText(  itemtype
					  , itemkey
					  , 'REPORT_APPROVER_FULL_NAME'
					  , l_forward_to_name);
			/* End of Addition for bug 4165780*/

			--debug_msg_s1 ('forward AAAAAAAAAAA  get approval comment: forward to = ' || l_forward_to_name);

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
						      , 'FORWARD_TO_USERNAME_RESPONSE' -- Changed 'FORWARD_TO' to 'FORWARD_TO_USERNAME_RESPONSE' for bug 4165780
						      , '');

		    END IF;

                    CLOSE is_user_valid;  -- #Bug 3905748




		   END IF;


		    resultout:='COMPLETE:'||'SUCCESS';

		    --resultout := wf_engine.eng_completed||':'||'T';


		END;

		 PROCEDURE post_notification(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

		  IS

		     cursor result_codes is
			select  wfl.lookup_code result_code
			  from    wf_lookups wfl,
			  wf_activities wfa,
			  wf_process_activities wfpa,
			  wf_items wfi
			  where   wfl.lookup_type         = wfa.result_type
			  and     wfa.name                = wfpa.activity_name
			  and     wfi.begin_date          >= wfa.begin_date
			  and     wfi.begin_date          < nvl(wfa.end_date,wfi.begin_date+1)
			  and     wfpa.activity_item_type = wfa.item_type
			  and     wfpa.instance_id        = actid
			  and     wfi.item_key            = itemkey
			  and     wfi.item_type           = itemtype;

		     default_result  varchar2(30) := '';

		BEGIN

		   --debug_msg_s1 ('call forward AAAAAAAAAAA' || funcmode);


		   for result_rec in result_codes LOOP

		      --debug_msg_s1 ('result' || result_rec.result_code);

		      default_result := result_rec.result_code;

		   END LOOP;

		   resultout := wf_engine.eng_completed||':'||default_result;
		    --resultout := wf_engine.eng_completed||':'||'T';


		END;

			PROCEDURE show_status_report
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
	  IS

	l_reported_by_id NUMBER;

	cursor pr_vals is
	select prval.version_id,prver.overview briefoverview, prval.attribute1 summary,prval.attribute2 issues,prval.attribute3 accomplishments,prval.attribute4 plans
	from pa_progress_report_vals prval, pa_progress_report_vers prver
	where prval.version_id = document_id
	and prver.version_id = document_id
	and region_code = 'PA_PROGRESS_GENERAL_TOP';

	CURSOR get_report_info IS
	   SELECT pprv.*, pl.meaning progress_status, papf.full_name FROM
	pa_progress_reports_v pprv,
	     pa_lookups pl,
	     pa_project_parties ppp,
    per_all_people_f papf
        where lookup_type like 'PROGRESS_SYSTEM_STATUS'
	AND pl.lookup_code = pprv.progress_status_code
	     and pprv.version_id  = document_id
	     AND pprv.object_type = 'PA_PROJECTS'
	     and papf.person_id = ppp.resource_source_id
	     AND pprv.reported_by = ppp.resource_id
	     AND ppp.object_id = pprv.object_id
	     and ppp.object_type = pprv.object_type
	     and trunc(sysdate) between papf.effective_START_DATE and nvl(papf.effective_END_DATE, sysdate+1);
	/*
   	SELECT pprv.*, pl.meaning progress_status FROM
	pa_progress_report_vers pprv,
	pa_lookups pl
        where lookup_type like 'PROGRESS_SYSTEM_STATUS'
	AND pl.lookup_code = pprv.progress_status_code
	and pprv.version_id  = document_id
	AND pprv.object_type = 'PA_PROJECTS';*/

	CURSOR c_reporter_list  IS
	select usr.user_id, usr.person_party_id, usr.user_name,papf.email_address,papf.full_name person_name -- Bug 4527617. Replaced customer_id with person_party_id.
	from per_all_people_f papf,
	fnd_user usr
	WHERE
	papf.person_id = usr.employee_id
	and    trunc(sysdate)
	between papf.EFFECTIVE_START_DATE
	and		  Nvl(papf.effective_end_date, Sysdate + 1)
	and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1)
	AND usr.user_id = l_reported_by_id;

	BEGIN


    document :=
'<table width=100% border=0 cellpadding=0 cellspacing=0><tr><td>
<table sumarry="" width=70% align=LEFT border=0 cellpadding=3 cellspacing=1 bgcolor=white>';
	for gri in get_report_info loop

	     document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report Type</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_type_name || ' ';
	      document := document ||'</font></td></tr>';

		   document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report Start Date</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_start_date || ' ';
	      document := document ||'</font></td></tr>';

	         document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report End Date</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_end_date || ' ';
	      document := document ||'</font></td></tr>';

	      l_reported_by_id :=gri.reported_by;

	      --debug_msg_s1 ('Reported by = ' || l_reported_by_id);

		       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Progress Status</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.progress_status || ' ';
	      document := document ||'</font></td></tr>';


	         document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Reported By</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.full_name || ' ';
	      document := document ||'</font></td></tr>';

	        document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Last Updated By</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.last_updated_by || ' ';
	      document := document ||'</font></td></tr>';


	end loop;

	for rec in pr_vals loop

		      document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Brief Overview</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.briefoverview || ' ';
	      document := document ||'</font></td></tr>';

	        document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Summary</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Summary || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Issues</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.issues || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Accomplishments</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Accomplishments || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Plans</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Plans || ' ';
	      document := document ||'</font></td></tr>';




	end loop;

	  document := document || '</table></td></tr></table>';

	document_type := 'text/html';

	END show_status_report;



	PROCEDURE show_status_report_cancel
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
	  IS

	     l_reported_by_id NUMBER;
	     l_comment VARCHAR2(240);
	cursor pr_vals is
	select prval.version_id,prver.overview briefoverview, prval.attribute1 summary,prval.attribute2 issues,prval.attribute3 accomplishments,prval.attribute4 plans
	from pa_progress_report_vals prval, pa_progress_report_vers prver
	where prval.version_id = document_id
	and prver.version_id = document_id
	and region_code = 'PA_PROGRESS_GENERAL_TOP';

	CURSOR get_report_info IS
	      SELECT pprv.*, pl.meaning progress_status, papf.full_name FROM
	pa_progress_reports_v pprv,
		pa_lookups pl,
		pa_project_parties ppp,
    per_all_people_f papf
        where lookup_type like 'PROGRESS_SYSTEM_STATUS'
	AND pl.lookup_code = pprv.progress_status_code
	and pprv.version_id  = document_id
	AND pprv.object_type = 'PA_PROJECTS'
		and papf.person_id = ppp.resource_source_id
		AND pprv.reported_by = ppp.resource_id
		AND ppp.object_id = pprv.object_id
		and ppp.object_type = pprv.object_type
		and    trunc(sysdate) between papf.effective_START_DATE and nvl(papf.effective_END_DATE, sysdate+1);
	/*
   	SELECT pprv.*, pl.meaning progress_status FROM
	pa_progress_report_vers pprv,
	pa_lookups pl
        where lookup_type like 'PROGRESS_SYSTEM_STATUS'
	AND pl.lookup_code = pprv.progress_status_code
	and pprv.version_id  = document_id
	AND pprv.object_type = 'PA_PROJECTS';*/

/*	CURSOR c_reporter_list  IS
	select usr.user_id, usr.customer_id, usr.user_name,papf.email_address,papf.full_name person_name
	from per_all_people_f papf,
	fnd_user usr
	WHERE
	papf.person_id = usr.employee_id
	and    trunc(sysdate)
	between papf.EFFECTIVE_START_DATE
	and		  Nvl(papf.effective_end_date, Sysdate + 1)
	and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1)
	AND usr.user_id = l_reported_by_id;
*/
	BEGIN


    document :=
'<table width=100% border=0 cellpadding=0 cellspacing=0><tr><td>
<table sumarry="" width=70% align=LEFT border=0 cellpadding=3 cellspacing=1 bgcolor=white>';
	for gri in get_report_info loop

	    document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report Type</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_type_name || ' ';
	      document := document ||'</font></td></tr>';

		   document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report Start Date</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_start_date || ' ';
	      document := document ||'</font></td></tr>';

	         document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report End Date</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_end_date || ' ';
	      document := document ||'</font></td></tr>';

	      l_reported_by_id :=gri.reported_by;



		document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Progress Status</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.progress_status || ' ';
	      document := document ||'</font></td></tr>';

document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Reported By</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.full_name || ' ';
	      document := document ||'</font></td></tr>';

	        document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Last Updated By</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.last_updated_by || ' ';
	      document := document ||'</font></td></tr>';



	      l_comment := gri.comments;


	end loop;

	for rec in pr_vals loop

		      document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Brief Overview</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.briefoverview || ' ';
	      document := document ||'</font></td></tr>';

	        document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Summary</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Summary || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Issues</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.issues || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Accomplishments</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Accomplishments || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Plans</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Plans || ' ';
	      document := document ||'</font></td></tr>';




	end loop;


	      document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Obsoletion Reason</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || l_comment || ' ';
	      document := document ||'</font></td></tr>';



	  document := document || '</table></td></tr></table>';

	document_type := 'text/html';

	END show_status_report_cancel;

	PROCEDURE show_status_report_submit
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
	  IS

	l_reported_by_id NUMBER;
	l_item_type VARCHAR2(200);
	l_item_key VARCHAR2(200);
	l_submitter_name VARCHAR2(200);

	cursor pr_vals is
	select prval.version_id,prver.overview briefoverview, prval.attribute1 summary,prval.attribute2 issues,prval.attribute3 accomplishments,prval.attribute4 plans
	from pa_progress_report_vals prval, pa_progress_report_vers prver
	where prval.version_id = document_id
	and prver.version_id = document_id
	and region_code = 'PA_PROGRESS_GENERAL_TOP';

	CURSOR get_report_info IS
	      SELECT pprv.*, pl.meaning progress_status, papf.full_name FROM
	pa_progress_report_vers pprv,
		pa_lookups pl,
		pa_project_parties ppp,
    per_all_people_f papf
        where lookup_type like 'PROGRESS_SYSTEM_STATUS'
	AND pl.lookup_code = pprv.progress_status_code
	and pprv.version_id  = document_id
	AND pprv.object_type = 'PA_PROJECTS'
		and papf.person_id = ppp.resource_source_id
	     AND pprv.reported_by = ppp.resource_id
		AND ppp.object_id = pprv.object_id
		and ppp.object_type = pprv.object_type
		and    trunc(sysdate) between papf.effective_START_DATE and nvl(papf.effective_END_DATE, sysdate+1);

	CURSOR get_wf_info is
	   select max(item_type), max(item_key) from pa_wf_processes,
	     pa_progress_report_vers pprv
	  where wf_type_code = 'Progress Report'
	    and entity_key2= document_id
	     AND entity_key1 = pprv.object_id
	     AND pprv.object_type = 'PA_PROJECTS'
	     AND pprv.version_id = document_id;


	/*
   	SELECT pprv.*, pl.meaning progress_status FROM
	pa_progress_report_vers pprv,
	pa_lookups pl
        where lookup_type like 'PROGRESS_SYSTEM_STATUS'
	AND pl.lookup_code = pprv.progress_status_code
	and pprv.version_id  = document_id
	AND pprv.object_type = 'PA_PROJECTS';*/

	  /*
	CURSOR c_reporter_list  IS
	select usr.user_id, usr.customer_id, usr.user_name,papf.email_address,papf.full_name person_name
	from per_all_people_f papf,
	fnd_user usr
	WHERE
	papf.person_id = usr.employee_id
	and    trunc(sysdate)
	between papf.EFFECTIVE_START_DATE
	and		  Nvl(papf.effective_end_date, Sysdate + 1)
	and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1)
	AND usr.user_id = l_reported_by_id;
	  */

	BEGIN


    document :=
'<table width=100% border=0 cellpadding=0 cellspacing=0><tr><td>
<table sumarry="" width=70% align=LEFT border=0 cellpadding=3 cellspacing=1 bgcolor=white>';
	for gri in get_report_info loop

		   document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report Start Date</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_start_date || ' ';
	      document := document ||'</font></td></tr>';

	         document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Report End Date</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.report_end_date || ' ';
	      document := document ||'</font></td></tr>';

	      l_reported_by_id :=gri.reported_by;
	      /*
		for crl in c_reporter_list loop


		   document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif">Reported By</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || crl.person_name || ' ';
	      document := document ||'</font></td></tr>';

		end loop;
		  */

		document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Progress Status</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || gri.progress_status || ' ';
	      document := document ||'</font></td></tr>';

	end loop;

	OPEN get_wf_info;
	FETCH get_wf_info INTO l_item_type, l_item_key;
	CLOSE get_wf_info;

	l_submitter_name := wf_engine.GetItemAttrText(  l_item_type
					  , l_item_key
							, 'SUBMITTER_FULL_NAME');

	document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Submitted By</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || l_submitter_name || ' ';
	      document := document ||'</font></td></tr>';

	for rec in pr_vals loop

		      document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Brief Overview</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.briefoverview || ' ';
	      document := document ||'</font></td></tr>';

	        document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Summary</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Summary || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Issues</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.issues || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Accomplishments</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Accomplishments || ' ';
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Plans</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor=#f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.Plans || ' ';
	      document := document ||'</font></td></tr>';




	end loop;
	  document := document || '</table></td></tr></table>';

	document_type := 'text/html';

	END show_status_report_submit;


	PROCEDURE show_project_info
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

	  IS

	        CURSOR get_project_info(l_project_id number) IS
	       SELECT
    /* Changed the query to base tables pa_projects_all and hr_all_organization_units instead of view
             pa_project_lists_v to improve performance. Bug :4940945 */
                     ppa.name,
		     PA_PROJECTS_MAINT_UTILS.GET_PRIMARY_CUSTOMER_NAME(PPA.PROJECT_ID) customer_name,
		               --project_type,
		               --to_char(project_value) as project_value,
		               --psi_projfunc_currency_code as project_currency_code,
		               --person_id,
		     PA_PROJECT_PARTIES_UTILS.GET_PROJECT_MANAGER_NAME(PPA.PROJECT_ID) person_name,
		     ppa.segment1,
		               --start_date,
		               --completion_date,
		     hou.name carrying_out_organization_name
		               --project_status_name,
		               --description
       	         FROM pa_projects_all ppa, hr_all_organization_units hou
		 WHERE ppa.project_id = l_project_id
                     and ppa.CARRYING_OUT_ORGANIZATION_ID = hou.ORGANIZATION_ID
		     and rownum = 1;
   /* changes end for bug 4940945 */
	BEGIN

	   --debug_msg_s1('Project Id ' || document_id);

	   document :=
'<table width=100% border=0 cellpadding=0 cellspacing=0><tr><td>
<table sumarry="" width=70% align=LEFT border=0 cellpadding=3 cellspacing=1 bgcolor=white>';


	     FOR rec IN get_project_info (document_id) LOOP


		--debug_msg_s1('Project Id 3' || document_id);
	      document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Project </font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.name|| '(' || rec.segment1 || ')';
	      document := document ||'</font></td></tr>';


	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Project Manager</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.person_name;
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Organization</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.carrying_out_organization_name;
	      document := document ||'</font></td></tr>';

	       document := document || '<tr><th scope=row width=40% align=RIGHT valign=baseline bgcolor=#cfe0f1><font color=#3c3c3c face="Arial, Helvetica, Geneva, sans-serif">Customer</font></th>';
	      document := document || '<td align=LEFT valign=baseline bgcolor= #f2f2f5><font color=black face="Arial, Helvetica, Geneva, sans-serif">';
	      document := document || rec.customer_name;
	      document := document ||'</font></td></tr>';

	      /*

		  document := document ||
		htf.tableRowOpen;

	        document := document ||
		htf.tableData('Project Name');

		document := document ||
		htf.tableData(rec.name);

		document := document ||
		  htf.tableRowClose;

		  document := document ||
		htf.tableRowOpen;

	        document := document ||
		htf.tableData('Project Manager');

		document := document ||
		htf.tableData(rec.person_name);

		document := document ||
		  htf.tableRowClose;

		  document := document ||
		htf.tableRowOpen;

	        document := document ||
		htf.tableData('Organization');

		document := document ||
		htf.tableData(rec.carrying_out_organization_name);

		document := document ||
		  htf.tableRowClose;

		  document := document ||
		htf.tableRowOpen;

	        document := document ||
		htf.tableData('Customer');

		document := document ||
		htf.tableData(rec.customer_name);

		document := document ||
		  htf.tableRowClose;
	      	*/
	   END LOOP;

	   /*document := document ||
	     htf.tableClose;*/

	       document := document ||'</table></td></tr></table>';

	   --debug_msg_s1('Docu = ' || document);

 	   document_type := 'text/html';

	END show_project_info;

	PROCEDURE show_report_content
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
		    where object_Type     = 'PA_PROGRESS_REPORTS'
		    and pk1_value         =  document_id;

	     l_size number;

	     l_chunk_size  pls_integer:=10000;
	     l_copy_size int;
	     l_pos int := 0;

	     l_line varchar2(30000) := '' ;

		 --Bug 3787169
		 l_return_status varchar2(1);
		 l_msg_count     number;
		 l_msg_data      varchar2(2000);

	BEGIN
	   --debug_msg_s1 ('get clob content');
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
		else
			close get_report_info;
	   END IF;

	   document_type := 'text/html';
	EXCEPTION
	   WHEN OTHERS THEN

	      --debug_msg_s1('Error '||TO_CHAR(SQLCODE)||': '||substr(Sqlerrm, 255));

	      WF_NOTIFICATION.WriteToClob(document, 'Report Content Generation failed');
	      dbms_lob.writeappend(document, 255, substr(Sqlerrm, 255));

	END show_report_content;

END pa_progress_report_WORKFLOW;


/
