--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_ASGMT_APPRVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_ASGMT_APPRVL" AUTHID CURRENT_USER AS
/*$Header: PARAAPCS.pls 120.5 2006/07/21 11:21:26 dthakker noship $*/
/*#
 * This extension enforces change in duration, change in work type conditions, and whether an approval is required for an assignment.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Assignment Approval Changes Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJ_RESOURCE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

--
--Determine if the specified assignment's approval required items have been changed or not.
--
/*#
 * This function returns a value (either Y or N) to indicate whether approval items have been changed.
 * @return Returns the flag to indicate whether approval items have been changed.
 * @param p_assignment_id The identifier of the assignment
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Changed Approval Items Assignment
 * @rep:compatibility S
*/
FUNCTION Is_Asgmt_Appr_Items_Changed
  (
   p_assignment_id             IN   pa_project_assignments.assignment_id%TYPE
  )
  RETURN VARCHAR2;

END PA_CLIENT_EXTN_ASGMT_APPRVL;

 

/
