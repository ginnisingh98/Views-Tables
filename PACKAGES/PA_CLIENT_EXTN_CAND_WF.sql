--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_CAND_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_CAND_WF" AUTHID CURRENT_USER AS
--  $Header: PARCWFCS.pls 120.4 2006/07/21 11:24:02 dthakker noship $
/*#
 * This client extension enables you to customize candidate workflow processes.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Candidate Approval Notification Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJ_RESOURCE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

TYPE Users_List_Rectyp   IS RECORD
(User_Name      VARCHAR2(320) ,   /* Modified VARCHAR2(30) for bug 3158966 */
 Person_id      NUMBER,
 Type           VARCHAR2(30),
 Routing_Order  NUMBER);

TYPE Users_List_Tbltyp IS TABLE OF Users_List_Rectyp
INDEX BY BINARY_INTEGER;

/*#
 * This procedure is used to generate a list of recipients for notifications. Oracle Project sends the list
 * of default approvers to this procedure. The procedure makes user-requested changes and provides a
 * modified list.
 * @param p_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_assignment_id The unique identifier of the assignment
 * @rep:paraminfo {@rep:required}
 * @param p_candidate_number The unique identifier of the candidate
 * @rep:paraminfo {@rep:required}
 * @param p_notification_type Type of notification
 * @rep:paraminfo {@rep:required}
 * @param p_in_list_of_recipients Input list of notification recipients
 * @rep:paraminfo {@rep:required}
 * @param x_out_list_of_recipients Output list of notification recipients
 * @rep:paraminfo {@rep:required}
 * @param x_number_of_recipients Number of recipients
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Notification Recipients
 * @rep:compatibility S
*/
PROCEDURE Generate_NF_Recipients
        (p_project_id              IN  NUMBER
        ,p_assignment_id           IN  NUMBER
        ,p_candidate_number        IN  NUMBER
        ,p_notification_type       IN  VARCHAR2
        ,p_in_list_of_recipients   IN  Users_List_tbltyp
        ,x_out_list_of_recipients  OUT NOCOPY Users_List_tbltyp /* Added NOCOPY for bug#2674619 */
        ,x_number_of_recipients    OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

END PA_CLIENT_EXTN_CAND_WF;
 

/
