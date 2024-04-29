--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_ASGMT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_ASGMT_WF" AS
--  $Header: PARAWFCB.pls 120.2 2006/06/28 07:28:51 sunkalya noship $



PROCEDURE Generate_Assignment_Approvers
    (p_assignment_id	            IN	NUMBER
     ,p_project_id	            IN	NUMBER
     ,p_in_list_of_approvers	    IN	Users_List_tbltyp
     ,x_out_list_of_approvers	   OUT	NOCOPY Users_List_tbltyp  -- For 1159 mandate changes bug#2674619
     ,x_number_of_approvers	   OUT	NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895
BEGIN
 -- This procedure , by default, returns the input approvers
 -- as output. You could customize this code to add or modify
 -- more approvers, as necessary. You must ensure that both
 -- x_out_list_of_approvers and x_number_of_approvers are properly
 -- populated. The calling apis used by Oracle Projects and Oracle
 -- Oracle Project Resource Management would use the output values

	x_out_list_of_approvers := p_in_list_of_approvers;
	IF p_in_list_of_approvers.EXISTS(1) THEN
	  x_number_of_approvers := p_in_list_of_approvers.COUNT;
        ELSE
	  x_number_of_approvers := 0;
	END IF;
END Generate_Assignment_Approvers;

PROCEDURE Generate_NF_Recipients
	( p_assignment_id	    IN	NUMBER
          ,p_project_id	            IN	NUMBER
          ,p_notification_type	    IN	VARCHAR2
          ,p_in_list_of_recipients  IN	Users_List_tbltyp
          ,x_out_list_of_recipients  OUT NOCOPY	Users_List_tbltyp  -- For 1159 mandate changes bug#2674619
          ,x_number_of_recipients    OUT	NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895
BEGIN
 -- This procedure , by default, returns the input recipients
 -- as output. You could customize this code to add or modify
 -- more recipients, as necessary. You must ensure that both
 -- x_out_list_of_recipients and x_number_of_recipients are properly
 -- populated. The calling apis used by Oracle Projects and Oracle
 -- Oracle Project Resource Management would use the output values
 -- You can use the p_notification_type parameter to distinguish
 -- between different types of notifications
 -- valid values in p_notification_type are 'APPROVAL_FYI'
 -- and 'REJECTION_FYI'
	x_out_list_of_recipients := p_in_list_of_recipients;
	IF p_in_list_of_recipients.EXISTS(1) THEN
	  x_number_of_recipients := p_in_list_of_recipients.COUNT;
        ELSE
	  x_number_of_recipients := 0;
        END IF;
END Generate_NF_Recipients;

PROCEDURE Set_Timeout_And_Reminders
	 ( p_assignment_id	    IN	NUMBER
	   ,p_project_id	            IN	NUMBER
	   ,x_waiting_time	   OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
	   ,x_number_of_reminders   OUT	NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895
BEGIN
-- This procedure returns the following
-- x_waiting_time - This is expressed in minutes and indicates
--		    the time the process has to wait before reminding
--		    the approver when the approver fails to respond
--		    to the approval notification.
--		    Note that the default supplied with the product is
--		    3 days , which is expressed in minutes
--		    as (3*24*60) = 4320. If you wish to change
--		    this , you would have to calculate the minutes
--		    appropriately. Note that the waiting time , referred to as
--		    timeouts by Oracle Workflow, has to be expressed in minutes
--		    only

-- x_number_of_reminders  - This indicates the number of times the approval
--		            has to remind the approver who has not responded
--			    to the approval notification
--		            By default this value is set to 3
--  Based on the defaults, the approval process would wait for 3 days
--  before issuing the first reminder. It will then issue two more reminders
--  before cancelling the notification and the project manager would be informed
--  of such cancellation

	   x_waiting_time  := 4320;
	   x_number_of_reminders   := 3;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END Set_Timeout_And_Reminders;

END PA_CLIENT_EXTN_ASGMT_WF ;

/
