--------------------------------------------------------
--  DDL for Package PA_PROGRESS_REPORT_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_REPORT_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: PAPRWFPS.pls 120.1 2005/08/19 16:45:47 mwasowic noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PAPRWFPS.pls
 DESCRIPTION :
               This file creates package procedures that are called to
               execute each activity in the Progress Status Workflow.



 HISTORY     : 06/22/00 SYAO Initial Creation
=============================================================================*/

Procedure  start_workflow(
			  p_item_type         IN     VARCHAR2
			  , p_process_name      IN     VARCHAR2

			  , p_version_id        IN     NUMBER

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

Procedure  get_workflow_url (
			     p_ItemType         IN     VARCHAR2
			     , p_ItemKey           IN     VARCHAR2
			     , x_URL               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     , x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
			     , x_msg_data        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			     );

PROCEDURE check_progress_status
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE change_status_rejected
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE change_status_working
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE change_status_approved
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE is_submitter_same_as_reporter
          (itemtype                      IN      VARCHAR2
           ,itemkey                       IN      VARCHAR2
           ,actid                         IN      NUMBER
           ,funcmode                      IN      VARCHAR2
           ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

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
    );

 PROCEDURE set_reminder_report_notify(
				      p_item_type         IN     VARCHAR2
				      , p_item_key          IN     NUMBER
				      , p_object_type       IN     VARCHAR2
				      , p_object_id         IN     NUMBER

				      , p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
				      , p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type

				      , x_action_line_audit_tbl  out NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type 			 --File.Sql.39 bug 4440895
				      );

 PROCEDURE set_missing_report_notify
	  (  p_item_type         IN     VARCHAR2
	     , p_item_key          IN     NUMBER
	     , p_object_type       IN     VARCHAR2
	     , p_object_id         IN     NUMBER

	     , p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
	     , p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type

	     , x_action_line_audit_tbl  out NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type 			 --File.Sql.39 bug 4440895
	     );

  PROCEDURE forward_notification(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
				 ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

   PROCEDURE post_notification(
					itemtype                      IN      VARCHAR2
					,itemkey                       IN      VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
			       ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

   PROCEDURE show_status_report
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE show_status_report_cancel
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE show_status_report_submit
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE show_project_info
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE show_report_content
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
	   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



END pa_progress_report_WORKFLOW;


 

/
