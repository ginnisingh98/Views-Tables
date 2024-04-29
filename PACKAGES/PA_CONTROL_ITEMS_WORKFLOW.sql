--------------------------------------------------------
--  DDL for Package PA_CONTROL_ITEMS_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_ITEMS_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: PACIWFPS.pls 120.2.12010000.2 2009/08/11 07:16:20 anuragar ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PACIWFPS.pls
 DESCRIPTION :
               This file creates package procedures that are called to
               execute each activity in the Progress Status Workflow.



 HISTORY     : 07/22/02 SYAO Initial Creation
               20/01/04 sanantha   Bug 3297238. FP M changes.
	       23/06/04 rasinha   Bug# 3691192 FP M Changes
	                          Added three procedures namely CLOSE_CI_ACTION,KEEP_OPEN and CANCEL_NOTIF_AND_ABORT_WF.
				  CLOSE_CI_ACTION and KEEP_OPEN are called from the PAWFCIAC workflow funtions.
				  CLOSE_CI_ACTION closes an Action without signing it off,
				  KEEP_OPEN keeps the action open and registers any comment given by the user and
				  CANCEL_NOTIF_AND_ABORT_WF cancels any open notification for an action and also aborts the workflow.
				  Also added some item attributes in the workflow PAWFCIAC.
	       10-Aug-05 rasinha  Bug# 4527911:
	                          1)Added the procedure close_notification to close an open action
				    notification.
				  2)Modifed the procedure CANCEL_NOTIF_AND_ABORT_WF .Added parameter
				    p_ci_action_id and removed the following parameters p_item_type,
				    p_item_key and p_nid.
=============================================================================*/

Procedure  start_workflow(
			  p_item_type         IN     VARCHAR2
			  , p_process_name      IN     VARCHAR2

			  , p_ci_id        IN     NUMBER

			  , x_item_key       OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  , x_msg_count      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
			  , x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  );

Procedure  cancel_workflow (
			    p_Item_type         IN     VARCHAR2
			    , p_Item_key        IN     VARCHAR2
			    , x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
			    , x_msg_data        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			    , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			    );

PROCEDURE change_status_rejected
          (itemtype                       IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE change_status_working
          (itemtype                       IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE change_status_approved
          (itemtype                       IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE is_approver_same_as_submitter(
	  itemtype                       IN      VARCHAR2
	  ,itemkey                       IN      VARCHAR2
	  ,actid                         IN      NUMBER
	  ,funcmode                      IN      VARCHAR2
	  ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895



PROCEDURE check_status_change
          (itemtype                       IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE approval_request_post_notfy
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE forward_notification(
					itemtype                       IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE show_clob_content
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3297238. FP M changes.
PROCEDURE START_NOTIFICATION_WF
   (  p_item_type		In		VARCHAR2
	,p_process_name	        In		VARCHAR2
	,p_ci_id		In		pa_control_items.ci_id%TYPE
	,p_action_id		In		pa_ci_actions.ci_action_id%TYPE := NULL
	,x_item_key		Out		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_return_status        Out             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count            Out             NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data             Out             NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Bug 3297238. FP M changes.
PROCEDURE set_workflow_attributes(
      p_item_type         In		VARCHAR2
     ,p_process_name      In		VARCHAR2
     ,p_ci_id             In		pa_control_items.ci_id%TYPE
     ,p_action_id         In		pa_ci_actions.ci_action_id%TYPE := NULL
     ,p_item_key          In		NUMBER
     ,x_return_status     Out		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count         Out		NOCOPY NUMBER   --File.Sql.39 bug 4440895
     ,x_msg_data          Out		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Bug# 3691192 FP M Changes
PROCEDURE CLOSE_CI_ACTION(
          itemtype                        IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--Bug# 3691192 FP M Changes
PROCEDURE KEEP_OPEN (
            itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Bug# 3691192 FP M Changes
PROCEDURE cancel_notif_and_abort_wf(
      p_ci_action_id    IN     NUMBER,
      x_msg_count       OUT    NOCOPY NUMBER    ,
      x_msg_data        OUT    NOCOPY VARCHAR2  ,
      x_return_status   OUT    NOCOPY VARCHAR2  );

PROCEDURE close_notification(
      p_item_type       in     VARCHAR2,
      p_item_key        in     VARCHAR2,
      p_nid             in     NUMBER,
      p_action          in     VARCHAR2,
      p_sign_off_flag   in     VARCHAR2,
      p_response        in     VARCHAR2,
      x_msg_count       OUT    NOCOPY NUMBER   ,
      x_msg_data        OUT    NOCOPY VARCHAR2 ,
      x_return_status   OUT    NOCOPY VARCHAR2 );
  PROCEDURE show_task_details
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, -- 4537865
	   document_type IN OUT NOCOPY VARCHAR2);

END pa_control_items_workflow;


/
