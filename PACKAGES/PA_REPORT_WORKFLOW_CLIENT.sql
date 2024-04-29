--------------------------------------------------------
--  DDL for Package PA_REPORT_WORKFLOW_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REPORT_WORKFLOW_CLIENT" AUTHID CURRENT_USER as
/* $Header: PAPRWFCS.pls 120.5 2006/07/25 07:12:12 sukhanna noship $ */
/*#
 * This extension enables you to customize the workflow processes for submitting, approving, and publishing a
 * project status report.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Status Report Workflow
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PERF_REPORTING
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PAPRWFCS.pls

 USAGE:    sqlplus apps/apps @PAPRWFCS.pls

 DESCRIPTION :
  This file provides client extension procedures for
  various Status Reports Workflow activities.

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
             : 04/22/04 mchava Interface Reporsitory Annotation Standards
                               are incorporated.
             : 02-Jun-2006 vgottimu Changed the doccd annotation file name to 120pjapi.pdf.
             : 03-Jul-2006 vgottimu Bug#5367820 Changed the descriptions of the
				    APIs and also changed the descriptions of parameters as suggested by Doc team
				    for IRep.
             : 24-Jul-2006 sukhanna Bug#5406254. Add business entity  PA_PERF_REPORTING
=============================================================================*/



/*#
 * This procedure starts the workflow process for a project status report.
 * You can modify this procedure to add company specific business rules
 * that are validated using this procedure.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_process_name Name of the workflow process
 * @rep:paraminfo {@rep:required}
 * @param p_item_key   The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param p_version_id    Identifier of the version
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data  API standard: error message
 * @rep:paraminfo {@rep:required}
 * @param x_return_status  API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Start Workflow
 * @rep:compatibility S
*/

Procedure  start_workflow (
			     p_item_type         IN     VARCHAR2
			   , p_process_name      IN     VARCHAR2
			   , p_item_key          IN     NUMBER
			   , p_version_id        IN     NUMBER

                           , x_msg_count         OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
			   , x_msg_data          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   , x_return_status     OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   );

/*#
 *This procedure determines the approver for the status report. You can modify the procedure to determine
 * the status report approver. The default procedure identifies the supervisor of the person
 * who submitted the status report.
 * @param p_item_type    The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_item_key   The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param actid Identifier of the action
 * @rep:paraminfo {@rep:required}
 * @param funcmode The workflow function mode
 * @rep:paraminfo {@rep:required}
 * @param resultout  Process result
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Report Approver
 * @rep:compatibility S
*/

PROCEDURE set_report_approver(
			       p_item_type                   IN      VARCHAR2
			      ,p_item_key                    IN      VARCHAR2
			      ,actid                         IN      NUMBER
			      ,funcmode                      IN      VARCHAR2

			      ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*#
 * This procedure determines which users receive workflow notifications
 * when a project status report is submitted, approved, rejected, or published.
 * @param p_item_type  The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_item_key  The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param p_status   The report status
 * @rep:paraminfo {@rep:required}
 * @param actid Identifier of the action
 * @rep:paraminfo {@rep:required}
 * @param funcmode Workflow function mode
 * @rep:paraminfo {@rep:required}
 * @param resultout  Process result
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Report Notification Party
 * @rep:compatibility S
*/

PROCEDURE set_report_notification_party(
			       		 p_item_type         IN      VARCHAR2
					,p_item_key          IN      VARCHAR2
					,p_status            IN      VARCHAR2
					,actid               IN      NUMBER
					,funcmode            IN      VARCHAR2

					,resultout           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					);



END pa_report_workflow_client;


 

/
