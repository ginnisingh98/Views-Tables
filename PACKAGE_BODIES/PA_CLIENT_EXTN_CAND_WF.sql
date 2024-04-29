--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_CAND_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_CAND_WF" AS
--  $Header: PARCWFCB.pls 120.1 2005/08/19 16:49:55 mwasowic noship $

-- DO NOT ADD OR MODIFY THE PARAMETERS OF ANY OF THE PROCEDURES IN THIS
-- PACKAGE. YOU CAN CODE YOUR OWN LOGIC IN ANY OF THE PROCEDURES.

PROCEDURE Generate_NF_Recipients
	(p_project_id              IN  NUMBER
	,p_assignment_id	   IN  NUMBER
        ,p_candidate_number        IN  NUMBER
        ,p_notification_type       IN  VARCHAR2
        ,p_in_list_of_recipients   IN  Users_List_tbltyp
        ,x_out_list_of_recipients  OUT NOCOPY Users_List_tbltyp /* Added NOCOPY for bug#2674619 */
        ,x_number_of_recipients    OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895
BEGIN
 -- This procedure , by default, returns the input recipients
 -- as output. You could customize this code to add or modify
 -- more recipients, as necessary. You must ensure that both
 -- x_out_list_of_recipients and x_number_of_recipients are properly
 -- populated. The calling apis used by Oracle Projects and Oracle
 -- Project Resource Management would use the output values.
 -- You can use the p_notification_type parameter to distinguish
 -- between different types of notifications
 -- valid values in p_notification_type are 'PENDING_REVIEW_FYI'
 -- and 'DECLINED_FYI'
	x_out_list_of_recipients := p_in_list_of_recipients;

	IF p_in_list_of_recipients.EXISTS(1) THEN
	  x_number_of_recipients := p_in_list_of_recipients.COUNT;
        ELSE
	  x_number_of_recipients := 0;
        END IF;
END Generate_NF_Recipients;

END PA_CLIENT_EXTN_CAND_WF ;

/
