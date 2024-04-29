--------------------------------------------------------
--  DDL for Package Body PA_REPORT_WORKFLOW_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REPORT_WORKFLOW_CLIENT" as
/* $Header: PAPRWFCB.pls 120.6.12010000.4 2009/12/18 00:00:51 skkoppul ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

  FILE NAME   : PAPRWFCB.pls

  DESCRIPTION :
  This file provides client extension procedures for
  various Status Reports Workflow activities.

  USAGE:    sqlplus apps/apps @PAPRWFCB.pls

  PROCEDURES AND PARAMETERS:

  start_workflow

    p_item_type:     The workflow item type.
    p_process_name:  Name of the workflow process.
    p_item_key:      The workflow item key.
    p_version_id:    Identifier of the version.
    x_msg_count:     The number of messages being sent.
    x_msg_data:      The content of the message.
    x_return_status: The return status of the message.


  set_report_approver

    p_process:       Name of the workflow process.
    p_item_key:      The workflow item key.
    actid:           Identifier of the action.
    funcmode:        Workflow function mode.
    resultout:       Process result.

  set_report_notification_party

    p_item_type:     The workflow item type.
    p_item_key:      The workflow item key.
    p_status:        The report status.
    actid:           Identifier of the action.
    funcmode:        Workflow function mode.
    resultout:       Process result.



  HISTORY     : 06/22/00 SYAO Initial Creation

 23-Apr-2003  sacgupta   Bug 2911451. Changes for Assignment Type Validation.
                         Included condition Assignment_type ='E' and
                         Primary_flag ='Y'in cursor l_approver_csr for
                         procedure set_report_approver

17-Feb-2004   sukhanna   Bug : 3448380
                         Added Check on assignment_type for CWK Changes.

07-Feb-2005   rvelusam   Bug : 4165764
                         In the procedure set_report_approver added new variable
			 l_approver_name. And changed to code to set the correct
			 'To' field value.
05-Aug-2005   raluthra   Bug 4527617. Replaced fnd_user.customer_id with
                         fnd_user.person_party_id for R12 ATG Mandate fix.
09-Feb-2006   posingha   Bug 4530998. Changed the l_org variable from VARCHAR(60) to
                         pa_project_lists_v.carrying_out_organization_name%TYPE to allow
                         longer organization names to be accepted.
31-Mar-2006   posingha   Bug 5027098, Added code to set the 'From' role attribute
                         value for notifications.
22-Feb-2007   posingha   Bug 5716959: Changed calls to deprecated
                         WF_DIRECTORY.AddUsersToAdHocRole.
                         instead directly called
                         WF_DIRECTORY.AddUsersToAdHocRole2 API
                         Changes done in : Start_Workflow
                                           Set_report_Approver
                                           Set_report_notification_party
26-Apr-2007   vvjoshi	 Bug#5962410 : Set an expiration date in CreateAdhocRole
			 procedure call.
16-Sep-2008   rthumma    Bug 6843694 : In procedure 'set_report_notification_party',
                         changed the calls from get_dist_list to get_dist_list_email.
22-Apr-2009   rthumma    Bug 8451949 : In start_workflow set the value of Attachment URL
                         if attachments are present for the status report.
18-Dec-2009  skkoppul    Bug 9033874: Modified c_reporter_list cursor in start_workflow
                         method to not consider customer while deriving the
                         recipients of Status Report.

=============================================================================*/

/*======================Beginning of template code=========================+

 The following templates demonstrate how you can use the client extension
 to customize the behavior of the Status Report Workflow.
 Three examples are included:
    1.   Start_Workflow: You can set additional Workflow Item Attributes

    2.   Set_report_Approver: You can override the logic to set your own
         approver for the Approvel Process

    3.   Set_report_notification_party: You can override the logic to set your
         own notification party for the Pulished, Obsoleted(Canceled),
         Rejected and Approved Notification message

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

  wf_engine.SetItemAttrNumber( p_item_type
  , p_item_key
  , 'VERSION_ID'
  , p_version_id
  );


  wf_engine.SetItemAttrNumber( p_item_type
  , p_item_key
  , 'WF_OBJECT_ID'
  , p_version_id
  );

  wf_engine.SetItemAttrText(itemtype => p_item_type,
  itemkey  => p_item_key,
  aname    => 'HISTORY',
  avalue   =>
  'PLSQL:PA_WORKFLOW_HISTORY.show_history/'||
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

 PROCEDURE set_report_approver(
  p_item_type                      IN      VARCHAR2
  ,p_item_key                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     VARCHAR2 )
  IS

  -- The Purpose of Procedure is to set the approver for the status report
  -- approval process.
  -- The way to set to approver is to set the workflow item attribute
  -- 'REPORT_APPROVER_NAME' . The approval process will pick
  -- up this value when it tries to decide to whom it should send out
  -- the notification.
  -- 'REPORT_APPROVER_NAME' is a workflow adhoc user role, which is created
  -- within this procedure.
  -- In Addition, you need to set 'REPORT_APPROVER_FULL_NAME' and
  -- 'REPORT_APPROVER_USER_NAME'. These item attributes will be used
  -- as placeholders to store the approver name for tracking purpose.




  -- define the cursors you will need to retrieve information

  -- define local variables you will need

  begin

  -- retrieve the item attributes from workflow process, such as Report Version
  -- ID, Submitted By ID, and Project Manager ID, etc. These attributes can
  -- be used to determine the approver of the Control Item

  -- create a adhoc role so that we can use this role for notification
  -- you can keep the logic of creating role in this procedure untouched.

  l_approval_role := 'APVR_' ||p_item_type ||  p_item_key;

  -- run the cursor the retrieve your approver, your approver needs to have
  -- user_name , person_name or email_address.
  -- this is part which you can override to insert your own logic

  -- create a adhoc user if the user does not exists in the system already.

  -- add user name to a user list. This user list can not have duplicate.
  -- so remove any duplicate if necessary.

  -- add user the adhoc role by calling  WF_DIRECTORY.AddUsersToAdHocRole
  -- you can look at the original code in the procedure for example.

  -- set the item attribute REPORT_APPROVER_FULL_NAME and
  -- REPORT_APPROVER_USER_NAME

  -- set item attribute REPORT_APPROVER_NAME
  -- this is very important, with out this attribute set, the approval process
  -- will not work

  -- set return result to wf_engine.eng_completed||':'||'T';

  -- save the comment history to record info such as
  -- "Submitter zzzz submit report xxx on this date"

  pa_workflow_history.save_comment_history (
  p_item_type
  ,p_item_key
  ,'SUBMIT'
  , l_user_name   --- Submitter User Name
  ,'');

  EXCEPTION

  WHEN OTHERS THEN
  RAISE;


  end set_report_approver;

  PROCEDURE set_report_notification_party(
  p_item_type   IN      VARCHAR2
  ,p_item_key   IN      VARCHAR2
  ,p_status IN VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     VARCHAR2
  )


  -- The Purpose of Procedure is to set the notification party for the
  -- published, obsoleted (canceled), rejected and approved message
  --
  -- The way to set to approver is to set the workflow item attribute
  -- 'REPORT_NOTFY_NAME'. The notification process will pick
  -- up this value when it tries to decide to whom it should send out
  -- the notification.


  -- define the cursors you will need to retrieve information

  -- define local variables you will need

  begin

  -- retrieve the item attributes from workflow process, such as Report Version
  -- ID, Project ID, etc.  These attributes can
  -- be used to determine the notification party.


  -- Determine the status of the report given the version ID. This will
  -- what kind of report we should send out (APPROVED, PUBLISHED, etc.)
  -- Based on the report notification type, we will select different users
  -- as notification party.

  -- create a adhoc role so that we can use this role for notification
  -- you can keep the logic of creating role in this procedure untouched.
  l_notify_role := 'RNT_' || p_item_type || p_item_key;


  -- run the cursor the retrieve your party, your party needs to have
  -- user_name , person_name or email_address.
  -- please note that in my original code, this is done through access list.
  -- this is part which you can override to insert your own logic

  -- create a adhoc user if the user does not exists in the system already.

  -- add user name to a user list. This user list can not have duplicate.
  -- so remove any duplicate if necessary.

  -- add user the adhoc role by calling  WF_DIRECTORY.AddUsersToAdHocRole
  -- you can look at the original code in the procedure for example.

  -- set the item attribute REPORT_NOTFY_NAME

  -- set return result based on the report status, PUBLISHED, REJECTED, etc.
  -- you should not customize this logic.


  end set_report_notification_party;

=============================================================================*/


        /********************************************************************
        * Procedure     : start_workflow
        *********************************************************************/
        Procedure  start_workflow
	 (
	    p_item_type         IN     VARCHAR2
	  , p_process_name      IN     VARCHAR2
	  , p_item_key          IN     NUMBER

	  , p_version_id        IN     NUMBER

	  , x_msg_count      out     NOCOPY NUMBER --File.Sql.39 bug 4440895
          , x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         )
        IS

	   l_project_name VARCHAR2(30);
	   l_project_number  VARCHAR2(25);

	   l_task_num    VARCHAR2(25);
	   l_task_name   VARCHAR2(20);
	   l_person_id     NUMBER;
	   l_name        VARCHAR2(250);
	   l_user_name        VARCHAR2(250);
	   l_status_code VARCHAR2(30);
	   l_submitter_role varchar2(30) := NULL;
	   l_reporter_role varchar2(30) := NULL;
	   l_role_users    varchar2(30000) := NULL;
	   l_reporter_role_users    varchar2(30000) := NULL;
	   l_reported_by_id NUMBER;
	   l_url     VARCHAR2(600);
	   l_url2     VARCHAR2(600);
	   l_user_id NUMBER;
	   l_approval_required VARCHAR2(10);
	   l_submitted_by_user_name VARCHAR2(100);
	   l_project_id NUMBER;
           l_role_users_table WF_DIRECTORY.UserTable; /*bug 5716959*/
           l_reporter_role_users_table WF_DIRECTORY.UserTable; /*bug 5716959*/
           l_count  NUMBER := 1; /*bug 5716959*/

	   CURSOR get_report_info IS
	       SELECT pprv.*, pl.meaning progress_status FROM
		pa_progress_reports_v pprv,
		pa_lookups pl
                where lookup_type like 'PROGRESS_SYSTEM_STATUS'
		AND pl.lookup_code = pprv.progress_status_code
		 and pprv.version_id  = p_version_id;


	   CURSOR  get_full_name_csr (l_person_id number)
             IS
		 select papf.full_name
                  from
                  per_all_people_f papf
                  WHERE
		   papf.person_id  = l_person_id;


	    CURSOR  get_user_name_csr (l_usr_id number)
             IS
		 SELECT fu.user_name
                  from
                  per_all_people_f papf, fnd_user fu
                  WHERE
		   fu.user_id  = l_usr_id
		   and
                  fu.employee_id = papf.person_id;


	   CURSOR c_submitter_list  IS
	      select UNIQUE usr.user_id, usr.person_party_id, usr.user_name,papf.email_address,papf.full_name person_name -- Bug 4527617. Replaced customer_id with person_party_id.
		  from per_all_people_f papf,
		             fnd_user usr
		  WHERE
		    papf.person_id = usr.employee_id
		    and    trunc(sysdate)
		    between papf.EFFECTIVE_START_DATE
		    and		  Nvl(papf.effective_end_date, Sysdate + 1)
		    and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1)
		AND usr.user_id = l_user_id;

	   CURSOR c_reporter_list  IS
	      select UNIQUE usr.user_id, usr.person_party_id, -- Bug 4527617. Replaced customer_id with person_party_id.
		usr.user_name,papf.email_address,papf.full_name person_name
		  from per_all_people_f papf,
		             fnd_user usr,
                     pa_project_parties ppp
		  WHERE
                    papf.person_id = usr.employee_id
		    and    trunc(sysdate)
		    between papf.EFFECTIVE_START_DATE
		    and		  Nvl(papf.effective_end_date, Sysdate + 1)
		    and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1)
		and papf.person_id = ppp.resource_source_id
                and ppp.resource_type_id <> 112 -- skkoppul addd for bug 9033874
		and ppp.object_id = l_project_id
		and ppp.object_type = 'PA_PROJECTS';


	    CURSOR get_approval_required IS
	       SELECT popl.approval_required
		 FROM pa_object_page_layouts popl, pa_progress_report_vers pprv
		 WHERE pprv.version_id = p_version_id
		 AND popl.object_id = pprv.object_id
		 AND popl.object_type = pprv.object_type
		 AND popl.page_id = pprv.page_id
		 and popl.report_type_id = pprv.report_type_id;


	    l_customer  VARCHAR2(4000);
	    l_project_manager  VARCHAR2(240);
	    l_org  pa_project_lists_v.carrying_out_organization_name%TYPE; --VARCHAR2(60); Modified for bug 4530998

	    CURSOR get_project_info(l_project_id number) IS
	       SELECT
		 customer_name,
		 person_name,
		 carrying_out_organization_name
		 FROM pa_project_lists_v
		 WHERE project_id = l_project_id;

	    CURSOR get_person_id_from_resource_id (l_resource_id number) IS
		 select resource_source_id from pa_project_parties
		 where object_id = l_project_id
		 and object_type = 'PA_PROJECTS'
		 and resource_id = l_resource_id;

	    l_find_duplicate VARCHAR2(1) := 'N';

	     display_name VARCHAR2(2000);
	     email_address VARCHAR2(2000);
	     notification_preference VARCHAR2(2000);
	     language VARCHAR2(2000);
	     territory VARCHAR2(2000);

	     -- Added for Bug 8451949
	     l_attachment_url     VARCHAR2(2000);
	     l_doc_attach_count   number;

        BEGIN

	   x_return_status := FND_API.G_RET_STS_SUCCESS;


	   wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'VERSION_ID'
                                      , p_version_id
					);


	     wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'WF_OBJECT_ID'
                                      , p_version_id
					  );

	       wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'HISTORY',
                              avalue   =>
                         'PLSQL:PA_WORKFLOW_HISTORY.show_history/'||
                         p_item_type||':'||
                         p_item_key );


	   -- set approval_required attribute

	   OPEN get_approval_required;
	   FETCH get_approval_required INTO l_approval_required;
	   CLOSE get_approval_required;

	   wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'AUTO_APPROVED'
                                      , l_approval_required
                                      );

	   -- set item attributes for the workflow process
	   FOR rec IN get_report_info LOOP


	      -- set project id
	      wf_engine.SetItemAttrText( p_item_type
					 , p_item_key
					 , 'REPORT_TYPE'
					 , rec.report_type_name);

	      wf_engine.SetItemAttrText( p_item_type
					 , p_item_key
					 , 'LAST_UPDATED_BY'
					 , rec.last_updated_by);


	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'PROJECT_ID'
                                      ,rec.object_id
					 );

	        l_url := 'JSP:OA_HTML/OA.jsp?paReportVersionId='||p_version_id ||'&paProjectId='||  rec.object_id||
		  '&akRegionCode=PA_PROG_REP_REVIEW_LAYOUT&akRegionApplicationId=275&paPageMode=APPROVE&addBreadCrumb=RP';

		l_url2 := 'JSP:/OA_HTML/OA.jsp?paReportVersionId='||p_version_id ||'&paProjectId='||  rec.object_id||
		  '&akRegionCode=PA_PROG_REP_REVIEW_LAYOUT&akRegionApplicationId=275&paPageMode=APPROVE&addBreadCrumb=RP';


	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'REPORT_LINK'
                                      , l_url2
					 );

	      l_project_id := rec.object_id;

	      -- set project manager, organization name and customer
	      OPEN get_project_info(rec.object_id);

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



	      -- set project name and number
	      pa_utils.getprojinfo(rec.object_id, l_project_number, l_project_name);


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



	      -- set record_version_number
	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'RECORD_VERSION_NUMBER'
                                      ,rec.record_version_number
					 );


	      -- set report start date
	      wf_engine.SetItemAttrDate( p_item_type
                                      , p_item_key
                                      , 'REPORT_START_DATE'
                                      ,rec.report_start_date
					 );

	      -- set progress status
	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'PROGRESS_STATUS'
                                      ,rec.progress_status
					 );


	       -- set report status code
	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'REPORT_STATUS'
                                      ,rec.report_status_code
					 );


	      -- set report end date
	      wf_engine.SetItemAttrDate( p_item_type
                                      , p_item_key
                                      , 'REPORT_END_DATE'
                                      ,rec.report_end_date
					 );

	      -- set reported by ID and Name

	      -- rec.reported_by is resource_id, we need to change to person_id


	      l_reported_by_id := pa_resource_utils.get_person_id(rec.reported_by);


	      wf_engine.SetItemAttrNumber( p_item_type
                                      , p_item_key
                                      , 'REPORTED_BY_ID'
                                      ,l_reported_by_id
					 );

	      -- send notification to reported by person


	      -- Role must be less than 30 chars and all uppsercase
	      l_reporter_role := 'RPTBY_' || p_item_type || p_item_key;


	      WF_DIRECTORY.CreateAdHocRole( role_name         => l_reporter_role
					    , role_display_name => l_reporter_role
					    , expiration_date   => sysdate+1); -- Set expiration_date for bug#5962410

	      -- l_reporter_role_users := NULL;  /* Commented for bug 5716959 */


	      for v_reporters in c_reporter_list loop

             --   if (l_reporter_role_users is not null) then
             --   l_reporter_role_users := l_reporter_role_users || ',';
	     --	 end if; */  /* Commented for Bug 5716959*/

		 -- Create adhoc users
		   wf_directory.getroleinfo(Upper(v_reporters.user_name),display_name,
					    email_address,notification_preference,language,territory);
		   if display_name is null THEN


		    WF_DIRECTORY.CreateAdHocUser( name => v_reporters.user_name
						  , display_name => v_reporters.person_name
						  --, notification_preference => 'MAILTEXT'
						  , EMAIL_ADDRESS =>v_reporters.email_address);

		 END IF;
	     --	 l_reporter_role_users := l_reporter_role_users || v_reporters.user_name; /* Commented for bug 5716959 */

		l_reporter_role_users_table(l_count) := v_reporters.user_name; /*bug 5716959*/
                l_count := l_count + 1; /*bug 5716959*/

 	      end loop;

             -- IF (l_reporter_role_users is NOT NULL) THEN /* commented out for Bug 5716959 */
                IF (l_reporter_role_users_table.COUNT > 0 ) THEN  /*bug 5716959*/


	     --	 WF_DIRECTORY.AddUsersToAdHocRole( l_reporter_role
	     --					   , l_reporter_role_users); -- /*Commented for Bug 5716959*/
                 WF_DIRECTORY.AddUsersToAdHocRole2( l_reporter_role
                                                   , l_reporter_role_users_table); /*bug 5716959 */


		 wf_engine.SetItemAttrText(  p_item_type
					     , p_item_key
					     , 'REPORTED_BY_NAME'
					     , l_reporter_role);
	      END IF;


	      OPEN get_full_name_csr(l_reported_by_id);
	      FETCH get_full_name_csr INTO l_name ;

	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'REPORTED_BY_FULL_NAME'
                                      , l_name
					 );


	      CLOSE get_full_name_csr;


	      -- set submitter by ID and Name

	      l_user_id := FND_GLOBAL.user_id;


	      wf_engine.SetItemAttrNumber( p_item_type
					   , p_item_key
					   , 'SUBMITTER_ID'
					   , l_user_id
					   );

	      OPEN get_full_name_csr(l_user_id);
	      FETCH get_full_name_csr INTO l_name;


	      wf_engine.SetItemAttrText( p_item_type
                                      , p_item_key
                                      , 'SUBMITTER_FULL_NAME'
                                      , l_name
					 );

	      CLOSE get_full_name_csr;


        /*Start of addition for bug 5027098 */
               wf_engine.SetItemAttrText(  p_item_type
                                  , p_item_key
                                  , 'FROM_ROLE_VALUE'
                                  , FND_GLOBAL.USER_NAME);
       /* End of addition for bug 5027098 */

       -- Bug 8451949
       select count(1) into l_doc_attach_count
       from FND_ATTACHED_DOCUMENTS
       WHERE entity_name = 'PA_PROGRESS_REPORTS'
         and PK1_Value = p_version_id;

       if (l_doc_attach_count > 0 ) then
         l_attachment_url := 'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pa/progress/webui/PaProgRepAttachPG'
                              ||'&'||'paReportVersionId='||p_version_id
                              ||'&'||'addBreadCrumb=Y';
         wf_engine.SetItemAttrText(  p_item_type
                                   , p_item_key
                                   , 'ATTACHMENT_URL'
                                   , l_attachment_url);
       end if;
       -- Bug 8451949

	   END LOOP;


	   -- set submitter info

	   -- Create adhoc role
	   -- Role must be less than 30 chars and all uppsercase
	   l_submitter_role := 'RPT_' || p_item_type || p_item_key;


	   WF_DIRECTORY.CreateAdHocRole( role_name         => l_submitter_role
                                       , role_display_name => l_submitter_role
					 , expiration_date   => sysdate+1); -- Set expiration_date for bug#5962410

           l_count := 1; /*Bug 5716959*/
	   for v_submitters in c_submitter_list loop

	      if (l_role_users is not null) then
		 l_role_users := l_role_users || ',';
	      end if;

	      -- Create adhoc users
	        wf_directory.getroleinfo(Upper(v_submitters.user_name),display_name,
					    email_address,notification_preference,language,territory);
		if display_name is null THEN


		 WF_DIRECTORY.CreateAdHocUser( name => v_submitters.user_name
					       , display_name => v_submitters.person_name
					       --, notification_preference => 'MAILTEXT'
					       , EMAIL_ADDRESS =>v_submitters.email_address);
	      END IF;
	      l_role_users := l_role_users || v_submitters.user_name;
	      l_role_users_table(l_count) := v_submitters.user_name; /*bug 5716959*/
              l_count := l_count + 1; /*bug 5716959*/
	      l_submitted_by_user_name := v_submitters.user_name;
	   end loop;


	   for v_reporters in c_reporter_list loop

	      l_find_duplicate := 'N';

	      IF (Instr(l_role_users, v_reporters.user_name||',') = 1) THEN
		 -- find duplicate
		 l_find_duplicate := 'Y';
	       ELSIF (Instr(l_role_users, ','||v_reporters.user_name||',') >0) THEN
		 -- find duplicate
		 l_find_duplicate := 'Y';
	       ELSIF (Instr(l_role_users, ','||v_reporters.user_name) = (Length(l_role_users)  - Length(v_reporters.user_name))) THEN
		 -- find duplicate
		 l_find_duplicate := 'Y';

	      END IF;


	      IF l_find_duplicate = 'N' THEN
		  if (l_role_users is not null) then
		     l_role_users := l_role_users || ',';
		  end if;

		  -- Create adhoc users
		     wf_directory.getroleinfo(Upper(v_reporters.user_name),display_name,
					    email_address,notification_preference,language,territory);
		if display_name is null THEN

		     WF_DIRECTORY.CreateAdHocUser( name => v_reporters.user_name
						   , display_name => v_reporters.person_name
						   --, notification_preference => 'MAILTEXT'
						   , EMAIL_ADDRESS =>v_reporters.email_address);

		     END IF;
		     l_role_users := l_role_users || v_reporters.user_name;
                     l_role_users_table(l_count) := v_reporters.user_name; /*bug 5716959*/
                     l_count := l_count + 1; /*bug 5716959*/
	      END IF;

	   end loop;


	-- IF (l_role_users is NOT NULL) THEN /* commented for bug 5716959 */
           IF (l_role_users_table.COUNT > 0) THEN /*bug 5716959*/


	   --   WF_DIRECTORY.AddUsersToAdHocRole( l_submitter_role
	   --					, l_role_users); /* commented for bug 5716959 */
                WF_DIRECTORY.AddUsersToAdHocRole2( l_submitter_role
                                                , l_role_users_table); /*bug 5716959*/


	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'REPORT_NOTFY_NAME'
					  , l_submitter_role);

	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'REPORT_SUBMITTER'
					  , l_submitter_role);


	   END IF;


        EXCEPTION

	   WHEN OTHERS THEN

	      x_msg_count := 1;
	      x_msg_data := substr(SQLERRM,1,2000);
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      RAISE;

        END start_workflow;


	 /********************************************************************
        * Procedure     : set_report_approver
        *********************************************************************/
	  PROCEDURE set_report_approver(
					p_item_type                      IN      VARCHAR2
					,p_item_key                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

	  IS


	     l_approval_role varchar2(30) := NULL;
	     l_role_users    varchar2(30000) := NULL;
	     l_version_id NUMBER;
	     l_reported_by_id NUMBER;
	     l_approver_id NUMBER;
	     l_approver_source_type NUMBER;
	     l_approver_name  per_all_people_f.full_name%type;  --Added for bug 4165764.

	     l_user_name        VARCHAR2(250);
             l_role_users_table WF_DIRECTORY.UserTable;  /*bug 5716959*/
             l_count NUMBER := 1;            /*bug 5716959*/
	     CURSOR get_user_name
	       IS
		  SELECT user_name
		    FROM fnd_user
		    WHERE user_id = FND_GLOBAL.user_id;

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

	         CURSOR get_approver_source_id
		   IS
		      select approver_source_id,
			approver_source_type
			from pa_progress_report_vers pprv,
			pa_object_page_layouts popl
			where pprv.object_id = popl.object_id
			and pprv.object_type = popl.object_type
			and pprv.report_type_id = popl.report_type_id
			and version_id = l_version_id;


	     CURSOR l_approver_csr is
		SELECT DISTINCT
		  fu.user_name,
		  p1.supervisor_id person_id, p2.full_name person_name, p2.email_address
		  FROM    per_assignments_f p1, per_all_people_f p2
		  , fnd_user fu
		  WHERE    p1.person_id = l_reported_by_id
		  and p1.supervisor_id = p2.person_id
                  AND p1.assignment_type in ('E', 'C')                      -- Added for bug 2911451
                  AND p1.primary_flag ='Y'                         -- Added for bug 2911451
		  AND TRUNC(sysdate) BETWEEN p1.EFFECTIVE_START_DATE
		  AND p1.EFFECTIVE_END_DATE                        -- Removed null for  bug 2911451
		  AND TRUNC(sysdate) BETWEEN p2.EFFECTIVE_START_DATE
		  AND NVL(p2.EFFECTIVE_END_DATE, sysdate)
		  AND fu.employee_id = p1.supervisor_id
		  ;

	       display_name VARCHAR2(2000);
	     email_address VARCHAR2(2000);
	     notification_preference VARCHAR2(2000);
	     language VARCHAR2(2000);
	     territory VARCHAR2(2000);

	  BEGIN

	     l_version_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'VERSION_ID');

	       l_reported_by_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'REPORTED_BY_ID');

	       l_approval_role := 'APVR_' ||p_item_type ||  p_item_key;

	     /* Commented for bug 4165764
	     WF_DIRECTORY.CreateAdHocRole( role_name         => l_approval_role
                                       , role_display_name => l_approval_role
                                       , expiration_date   => null
					  );  */



	       OPEN get_approver_source_id;
	       FETCH get_approver_source_id INTO l_approver_id, l_approver_source_type;



	   IF get_approver_source_id%notfound OR
	     l_approver_id IS NULL THEN


	      -- if no approver select from setup
	      CLOSE get_approver_source_id;
	      for v_approvers in l_approver_csr loop


              --  if (l_role_users is not null) then
              --  l_role_users := l_role_users || ',';
	      --  end if; /* commented for bug 5716959 */

		 -- Create adhoc users
		   wf_directory.getroleinfo(Upper(v_approvers.user_name),display_name,
					    email_address,notification_preference,language,territory);
		   if display_name is null THEN


		    WF_DIRECTORY.CreateAdHocUser( name => v_approvers.user_name
						  , display_name => v_approvers.person_name
						  --, notification_preference => 'MAILTEXT'
						  , EMAIL_ADDRESS =>v_approvers.email_address);


		 END IF;


		 wf_engine.SetItemAttrText(  p_item_type
					     , p_item_key
					     , 'REPORT_APPROVER_FULL_NAME'
					     , v_approvers.person_name);


		 wf_engine.SetItemAttrText(  p_item_type
					     , p_item_key
					     , 'REPORT_APPROVER_USER_NAME'
					     , v_approvers.user_name);

	     --  l_role_users := l_role_users || v_approvers.user_name; /* commented out for bug 5716959*/
                 l_role_users_table(l_count) := v_approvers.user_name; /*bug 5716959 */
                 l_count := l_count + 1; /*bug 5716959 */
	      end loop;
	    ELSE
	      CLOSE get_approver_source_id;


	      IF l_approver_source_type = 101 THEN
		 -- source type is person


		 for v_approvers in l_report_approver_csr_person loop
		 --   if (l_role_users is not null) then
		 --      l_role_users := l_role_users || ',';
		 --   end if;  /* commented for bug 5716959 */

		    -- Create adhoc users
		      wf_directory.getroleinfo(Upper(v_approvers.user_name),display_name,
					    email_address,notification_preference,language,territory);
		   if display_name is null THEN


		       WF_DIRECTORY.CreateAdHocUser( name => v_approvers.user_name
						     , display_name => v_approvers.person_name
						     --, notification_preference => 'MAILTEXT'
						     , EMAIL_ADDRESS =>v_approvers.email_address);

		    END IF;
		    wf_engine.SetItemAttrText(  p_item_type
						, p_item_key
						, 'REPORT_APPROVER_FULL_NAME'
						, v_approvers.person_name);

		    wf_engine.SetItemAttrText(  p_item_type
						, p_item_key
						, 'REPORT_APPROVER_USER_NAME'
						, v_approvers.user_name);

		   -- l_role_users := l_role_users || v_approvers.user_name; /* commented for bug 5716959 */
                      l_role_users_table(l_count) := v_approvers.user_name; /*bug 5716959 */
                      l_count := l_count + 1; /*bug 5716959 */
		 END LOOP;
	       ELSIF l_approver_source_type = 112 THEN

		 for v_approvers in l_report_approver_csr_party loop
		--     if (l_role_users is not null) then
		--     l_role_users := l_role_users || ',';
		--     end if; /* commented for bug 5716959 */

		    -- Create adhoc users
		    wf_directory.getroleinfo(Upper(v_approvers.user_name),display_name,
					     email_address,notification_preference,language,territory);
		    if display_name is null THEN


		       WF_DIRECTORY.CreateAdHocUser( name => v_approvers.user_name
						     , display_name => v_approvers.person_name
						     --, notification_preference => 'MAILTEXT'
						     , EMAIL_ADDRESS =>v_approvers.email_address);
		    END IF;

		    wf_engine.SetItemAttrText(  p_item_type
						, p_item_key
						, 'REPORT_APPROVER_FULL_NAME'
						, v_approvers.person_name);
		    wf_engine.SetItemAttrText(  p_item_type
						, p_item_key
						, 'REPORT_APPROVER_USER_NAME'
						, v_approvers.user_name);


		--  l_role_users := l_role_users || v_approvers.user_name; /* commented for bug 5716959 */
                    l_role_users_table(l_count) := v_approvers.user_name; /*bug 5716959 */
                    l_count := l_count + 1; /*bug 5716959 */
		 END LOOP;
	      END IF;

	   END IF;

	   --Start of addition for bug 4165764
	   l_approver_name :=wf_engine.GetItemAttrText(  p_item_type
						, p_item_key
						, 'REPORT_APPROVER_FULL_NAME'
						);
	   WF_DIRECTORY.CreateAdHocRole( role_name         => l_approval_role
                                       , role_display_name => l_approver_name
                                       , expiration_date   => sysdate+1  -- Set expiration_date for bug#5962410
					  );

	  -- End of Addition for bug 4165764

	--  IF (l_role_users is NOT NULL) THEN /* commented for bug 5716959 */
              IF (l_role_users_table.COUNT > 0 ) THEN /* bug 5716959  */
        --      WF_DIRECTORY.AddUsersToAdHocRole( l_approval_role
	--					, l_role_users); /* commented for bug 5716959 */

                WF_DIRECTORY.AddUsersToAdHocRole2( l_approval_role
                                                , l_role_users_table); /*bug 5716959 */

	      wf_engine.SetItemAttrText(  p_item_type
					  , p_item_key
					  , 'REPORT_APPROVER_NAME'
					  , l_approval_role);


	      resultout := wf_engine.eng_completed||':'||'T';

	      OPEN get_user_name;
	      FETCH get_user_name INTO l_user_name;
	      CLOSE get_user_name;




	      pa_workflow_history.save_comment_history (
						   p_item_type
						   ,p_item_key
						   ,'SUBMIT'
						   , l_user_name
						   ,'');

	    ELSE

	      resultout := wf_engine.eng_completed||':'||'F';
	   END IF;



	   commit;



	EXCEPTION

	   WHEN OTHERS THEN
	      RAISE;

	END set_report_approver;


	/********************************************************************
        * Procedure     : set_report_notification_party
        *********************************************************************/
	PROCEDURE set_report_notification_party(
						p_item_type   IN      VARCHAR2
						,p_item_key   IN      VARCHAR2
						,p_status IN VARCHAR2
						,actid                         IN      NUMBER
						,funcmode                      IN      VARCHAR2
						,resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
						)

	  IS

	     l_version_id NUMBER;
	     l_project_id NUMBER;
	     l_object_page_layout_id NUMBER;
	     l_notify_role varchar2(30) := NULL;
	     l_role_users    varchar2(30000) := NULL;

	     l_user_names         pa_distribution_list_utils.pa_vc_1000_150 := null;
	     l_full_names         pa_distribution_list_utils.pa_vc_1000_150 := null;
	     l_email_addresses    pa_distribution_list_utils.pa_vc_1000_150 := null;
	     l_return_status      VARCHAR2(1);
	     l_msg_count          NUMBER;
	     l_msg_data           VARCHAR2(2000);
	     i INTEGER;

             l_role_users_table  WF_DIRECTORY.UserTable;  /*bug 5716959*/
             l_count NUMBER := 1 ; /*bug 5716959 */

	     CURSOR get_object_page_layout_id
	       IS
		  select popl.object_page_layout_id
		    from pa_object_page_layouts popl,
		    pa_progress_report_vers pprv
		    where popl.object_id = l_project_id
		    and popl.object_type = 'PA_PROJECTS'
		    and popl.page_type_code = 'PPR'
		    and sysdate between popl.effective_from and nvl(popl.effective_to, sysdate+1)
		    and pprv.version_id = l_version_id
		    and pprv.report_type_id = popl.report_type_id;


	     CURSOR get_proj_mgr
	       IS
		  SELECT
		    usr.user_id, usr.person_party_id, usr.user_name,papf.email_address,papf.full_name person_name -- Bug 4527617. Replaced customer_id with person_party_id.
		    FROM pa_project_lists_v pplv,
		    per_all_people_f papf,
		    fnd_user usr
		    WHERE pplv.project_id = l_project_id
		    and   papf.person_id = usr.employee_id
		    and    trunc(sysdate)
		    between papf.EFFECTIVE_START_DATE
		    and		  Nvl(papf.effective_end_date, Sysdate + 1)
		    and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1)
		    and papf.person_id = pplv.person_id;

	     l_submitter_role varchar2(30) := NULL;
	     l_find_duplicate VARCHAR2(1) := 'N';
	     display_name VARCHAR2(2000);
	     email_address VARCHAR2(2000);
	     notification_preference VARCHAR2(2000);
	     language VARCHAR2(2000);
	     territory VARCHAR2(2000);
	BEGIN

	     l_version_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'VERSION_ID');


	     l_project_id     := wf_engine.GetItemAttrNumber
               ( itemtype       => p_item_type,
                 itemkey        => p_item_key,
                 aname          => 'PROJECT_ID');

	     OPEN get_object_page_layout_id;
	     FETCH get_object_page_layout_id INTO l_object_page_layout_id;
	     CLOSE get_object_page_layout_id;

	     IF (p_status = 'PROGRESS_REPORT_PUBLISHED'  or
	       p_status = 'PROGRESS_REPORT_CANCELED'
	       )THEN
		-- set notifcation party for project people with View
		-- privilege

		-- Create adhoc role
		-- Role must be less than 30 chars and all uppsercase
		l_notify_role := 'RNT_' || p_item_type || p_item_key;




		WF_DIRECTORY.CreateAdHocRole( role_name         => l_notify_role
					      , role_display_name => l_notify_role
					      , expiration_date   => sysdate+1); -- Set expiration_date for bug#5962410


		-- Bug 6843694 : Changed call to procedure get_dist_list_email
		PA_DISTRIBUTION_LIST_UTILS.get_dist_list_email
		  (

		   'PA_OBJECT_PAGE_LAYOUT',
		   l_object_page_layout_id,

		   1,  -- view priv
		   l_user_names         ,
		   l_full_names         ,
		   l_email_addresses    ,
		   l_return_status      ,
		   l_msg_count          ,
		   l_msg_data
		   );




		IF (l_return_status = 'S' AND l_user_names IS NOT null) THEN

		   FOR i in l_user_names.First..l_user_names.LAST LOOP
		      IF l_user_names(i) IS NULL THEN


			 l_user_names(i) := Upper(l_email_addresses(i));
			l_full_names(i) := l_email_addresses(i);
		    END IF;

		      if (l_role_users is not null) then
			 l_role_users := l_role_users || ',';
		      end if;



		        wf_directory.getroleinfo(Upper(l_user_names(i)),display_name,
					    email_address,notification_preference,language,territory);
			if display_name is null THEN


			   WF_DIRECTORY.CreateAdHocUser( name => l_user_names(i)
							 , display_name => l_full_names(i)
							 , EMAIL_ADDRESS =>l_email_addresses(i));
			END IF;
			l_role_users := l_role_users || l_user_names(i);
	                l_role_users_table(l_count) := l_user_names(i); /*bug 5716959*/
                        l_count :=  l_count + 1 ; /*bug 5716959*/
        	   end loop;

		END IF;


	  --	IF (l_role_users is NOT NULL) THEN /* commented out for bug 5716959 */
                IF (l_role_users_table.COUNT > 0) THEN /* bug 5716959  */

          --      WF_DIRECTORY.AddUsersToAdHocRole( l_notify_role
	  --					     , l_role_users); /* commented for bug 5716959 */
                  WF_DIRECTORY.AddUsersToAdHocRole2( l_notify_role
                                                     , l_role_users_table); /*bug 5716959 */

		   wf_engine.SetItemAttrText(  p_item_type
					       , p_item_key
					       , 'REPORT_NOTFY_NAME'
					       , l_notify_role);
		END IF;

		IF p_status = 'PROGRESS_REPORT_CANCELED' THEN
		   resultout := wf_engine.eng_completed||':'||'CANCELED';
		 ELSIF p_status = 'PROGRESS_REPORT_PUBLISHED' then
		   resultout := wf_engine.eng_completed||':'||'PUBLISHED';
		END IF;

	      ELSIF (p_status = 'PROGRESS_REPORT_REJECTED'  or
		     p_status = 'PROGRESS_REPORT_APPROVED' )THEN

		IF p_status = 'PROGRESS_REPORT_REJECTED' then
		   resultout := wf_engine.eng_completed||':'||'REJECTED';
		 ELSIF p_status = 'PROGRESS_REPORT_APPROVED' THEN
		   resultout := wf_engine.eng_completed||':'||'APPROVED';
		END IF;


		-- Create adhoc role
		-- Role must be less than 30 chars and all uppsercase
		l_notify_role := 'RNT_' || p_item_type || p_item_key;


 		WF_DIRECTORY.CreateAdHocRole( role_name         => l_notify_role
					      , role_display_name => l_notify_role
					      , expiration_date   => sysdate+1); -- Set expiration_date for bug#5962410

 		-- Bug 6843694 : Changed call to procedure get_dist_list_email
 		PA_DISTRIBUTION_LIST_UTILS.get_dist_list_email
		  (

		   'PA_OBJECT_PAGE_LAYOUT',
		    l_object_page_layout_id,
		   2,  -- view priv
		   l_user_names         ,
		   l_full_names         ,
		   l_email_addresses    ,
		   l_return_status      ,
		   l_msg_count          ,
		   l_msg_data
		   );

		IF (l_return_status = 'S' AND l_user_names IS NOT null) THEN

	       FOR i in l_user_names.First..l_user_names.LAST LOOP

		  if (l_role_users is not null) THEN
		     IF l_user_names(i) IS NULL THEN
			--EXIT ;
			l_user_names(i) := Upper(l_email_addresses(i));
			l_full_names(i) := l_email_addresses(i);

		    END IF;

		    l_role_users := l_role_users || ',';
		 end if;


		  wf_directory.getroleinfo(Upper(l_user_names(i)),display_name,
					    email_address,notification_preference,language,territory);
		  if display_name is null THEN

		     WF_DIRECTORY.CreateAdHocUser( name => l_user_names(i)
						   , display_name => l_full_names(i)
						   , EMAIL_ADDRESS =>l_email_addresses(i));
		  END IF;
		  l_role_users := l_role_users || l_user_names(i);
                  l_role_users_table(l_count) := l_user_names(i);  /*bug 5716959*/
                  l_count :=  l_count + 1 ; /*bug 5716959*/
	       end loop;

	      END IF;


	      --get proj mgr
	      for v_people in get_proj_mgr loop


		   l_find_duplicate := 'N';


		   -- check if there are duplicate names
		   IF (l_role_users IS NOT NULL AND Instr(l_role_users, ',')<1) THEN
		      -- only one name in the role_users
		      IF (Instr(l_role_users, v_people.user_name) > 0) THEN
			 -- find duplicate
			 l_find_duplicate := 'Y';
		      END IF;
		    ELSIF l_role_users IS NOT NULL THEN
		      IF (Instr(l_role_users, v_people.user_name||',') = 1) THEN
			 -- find duplicate
			 l_find_duplicate := 'Y';
		       ELSIF (Instr(l_role_users, ','||v_people.user_name||',') >0) THEN
			 -- find duplicate
			 l_find_duplicate := 'Y';
		       ELSIF (Instr(l_role_users, ','||v_people.user_name) = (Length(l_role_users)  - Length(v_people.user_name))) THEN
		         -- find duplicate
			 l_find_duplicate := 'Y';

		      END IF;
		   END IF;

		   IF l_find_duplicate = 'N' then
		      if (l_role_users is not null) then
			 l_role_users := l_role_users || ',';
		      end if;


		      -- Create adhoc users
		      wf_directory.getroleinfo(Upper(v_people.user_name),
					       display_name,
					       email_address,
					       notification_preference,
					       language,territory);
		      if display_name is null THEN

			 WF_DIRECTORY.CreateAdHocUser( name => v_people.user_name
						       , display_name => v_people.person_name
						       --, notification_preference => 'MAILTEXT'
						       , EMAIL_ADDRESS =>v_people.email_address);
		      END IF;
		      l_role_users := l_role_users || v_people.user_name;
                      l_role_users_table(l_count) := l_user_names(i);  /*bug 5716959*/
                      l_count :=  l_count + 1 ; /*bug 5716959*/
		   END IF;

	      end loop;

	  --    IF (l_role_users is NOT NULL) THEN /* commented for bug 5716959 */
                IF (l_role_users_table.COUNT > 0) THEN  /*bug 5716959*/
	  --	 WF_DIRECTORY.AddUsersToAdHocRole( l_notify_role
	  --					   , l_role_users); /* commented for bug 5716959 */
	         WF_DIRECTORY.AddUsersToAdHocRole2( l_notify_role
                                                   , l_role_users_table); /*bug 5716959*/

		 wf_engine.SetItemAttrText(  p_item_type
					     , p_item_key
					     , 'REPORT_NOTFY_NAME'
					     , l_notify_role);
	      END IF;

	     END IF;

	EXCEPTION
	   WHEN OTHERS then
	      NULL;


	END set_report_notification_party;



END pa_report_workflow_client;


/
