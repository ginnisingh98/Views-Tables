--------------------------------------------------------
--  DDL for Package PA_CONTROL_ITEMS_WF_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_ITEMS_WF_CLIENT" AUTHID CURRENT_USER as
/* $Header: PACIWFCS.pls 120.4 2006/07/04 05:54:24 vgottimu noship $ */
/*#
 *This extension enables you to customize the workflow processes for
 * submitting and approving issues and change documents.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Issue and Change Workflow Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PACIWFCS.pls
 DESCRIPTION :
  This file provided client extension procedures that are called
  to execute each activity in the Issue and Change Document Workflow.

 PROCEDURES AND PARAMETERS

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


 HISTORY     : 06/22/00 SYAO Initial Creation
               04/22/04 mchava Interface Reporsitory Annotation Standards
                               are incorporated.
               02-JUN-2006 vgottimu Changed the doccd file name from 115pjoug.pdf to 120pjapi.pdf.
               03-JUL-2006 vgottimu Bug#5367820 Changed the description of APIs and paramenter
			            description as suggested by the Doc Team for IRep.
=============================================================================*/



/*#
 * This procedure is used to start the workflow process for issue and change document approval.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_process_name Name of the workflow process
 * @rep:paraminfo {@rep:required}
 * @param  p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param  p_ci_id The identifier of the control item
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Workflow
 * @rep:compatibility S
*/

Procedure  start_workflow (
			   p_item_type         IN     VARCHAR2
			   , p_process_name      IN     VARCHAR2
			   , p_item_key          IN     NUMBER

			   , p_ci_id        IN     NUMBER

			   , x_msg_count      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
			   , x_msg_data       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   , x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   );

/*#
 * This procedure is used to specify persons who can approve issues and change documents.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param  p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param actid The identifier of the action
 * @rep:paraminfo {@rep:required}
 * @param funcmode The workflow function mode
 * @rep:paraminfo {@rep:required}
 * @param resultout The process result
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Control Item Approver
 * @rep:compatibility S
*/

PROCEDURE set_ci_approver(
			      p_item_type                      IN      VARCHAR2
			      ,p_item_key                       IN      VARCHAR2
			      ,actid                         IN      NUMBER
			      ,funcmode                      IN      VARCHAR2
			      ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


/*#
 * This  procedure is used to specify persons who would be notified about approved and rejected issues and change documents.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param  p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param  p_status The control item status
 * @rep:paraminfo {@rep:required}
 * @param actid The identifier of the action
 * @rep:paraminfo {@rep:required}
 * @param funcmode The workflow function mode
 * @rep:paraminfo {@rep:required}
 * @param resultout The process result
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Notification Party
 * @rep:compatibility S
*/
PROCEDURE  set_notification_party(
					p_item_type   IN      VARCHAR2
					,p_item_key   IN      VARCHAR2
					,p_status IN VARCHAR2
					,actid                         IN      NUMBER
					,funcmode                      IN      VARCHAR2
					,resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					) ;


END pa_control_items_wf_client;


 

/
