--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_ASGMT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_ASGMT_WF" AUTHID CURRENT_USER AS
--  $Header: PARAWFCS.pls 120.6 2006/07/26 10:49:03 dthakker noship $
/*#
 * This client extension enables you to customize assignment approval workflow processes for generating
 * assignment approvers and notification recipients.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Assignment Approval Notification Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJ_RESOURCE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

TYPE Users_List_Rectyp   IS RECORD
(User_Name      VARCHAR2(100) ,                       /* Modified length of user_name to 100 from 30 for bug 3148857 */
 Person_id      NUMBER,
 Type           VARCHAR2(30),
 Routing_Order  NUMBER );

TYPE Users_List_Tbltyp IS TABLE OF Users_List_Rectyp
INDEX BY BINARY_INTEGER;



/*#
 * This procedure is used to generate a list of approvers for the assignment. Oracle Project sends the list
 * of default approvers to this procedure. The procedure makes the changes requested by user, and provides a
 * modified list of approvers.
 * @param p_assignment_id The unique identifier of the assignment
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_in_list_of_approvers Input list of notification recipients
 * @rep:paraminfo {@rep:required}
 * @param x_out_list_of_approvers Output list of notification recipients
 * @rep:paraminfo {@rep:required}
 * @param x_number_of_approvers Number of recipients
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Assignment Approvers
 * @rep:compatibility S
*/
  PROCEDURE Generate_Assignment_Approvers
    (p_assignment_id                IN  NUMBER
     ,p_project_id                  IN  NUMBER
     ,p_in_list_of_approvers        IN  Users_List_tbltyp
     ,x_out_list_of_approvers      OUT  NOCOPY Users_List_tbltyp  -- For 1159 mandate changes bug#2674619
     ,x_number_of_approvers        OUT  NOCOPY NUMBER ); --File.Sql.39 bug 4440895

/*#
 * This procedure is used to generate a list of recipients for notifications. Oracle Projects sends the list
 * of default approvers to this procedure. The procedure makes the changes requested by user, and provides a
 * modified list of recipients.
 * @param p_assignment_id The unique identifier of the assignment
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_notification_type Type of notification
 * @rep:paraminfo {@rep:required}
 * @param p_in_list_of_recipients Input list of notification recipients
 * @rep:paraminfo {@rep:required}
 * @param x_out_list_of_recipients Output list of notification recipient
 * @rep:paraminfo {@rep:required}
 * @param x_number_of_recipients Number of recipients
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Notification Recipients
 * @rep:compatibility S
*/
  PROCEDURE Generate_NF_Recipients
        ( p_assignment_id           IN  NUMBER
          ,p_project_id             IN  NUMBER
          ,p_notification_type      IN  VARCHAR2
          ,p_in_list_of_recipients   IN Users_List_tbltyp
          ,x_out_list_of_recipients  OUT  NOCOPY  Users_List_tbltyp  -- For 1159 mandate changes bug#2674619
          ,x_number_of_recipients    OUT        NOCOPY NUMBER ); --File.Sql.39 bug 4440895

/*#
 * This procedure is used to set reminder parameters, such as the waiting period between reminders and the number
 * of reminders that are issued before the workflow process is canceled.
 * @param p_assignment_id The unique identifier of the assignment
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The unique identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_waiting_time The maximum amount of time to wait before sending a reminder
 * @rep:paraminfo {@rep:required}
 * @param x_number_of_reminders The maximum number of reminders to send before aborting the process
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Timeout and Reminders
 * @rep:compatibility S
*/
   PROCEDURE Set_Timeout_And_Reminders
         ( p_assignment_id          IN  NUMBER
           ,p_project_id                    IN  NUMBER
           ,x_waiting_time         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_number_of_reminders   OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

END PA_CLIENT_EXTN_ASGMT_WF ;

 

/
