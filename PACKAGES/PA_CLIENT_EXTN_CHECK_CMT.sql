--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_CHECK_CMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_CHECK_CMT" AUTHID CURRENT_USER AS
/* $Header: PACECMTS.pls 120.1 2006/07/21 09:18:15 ajdas noship $*/
/*#
 * When you run the PRC:Update Project Summary Amounts process,Oracle Projects checks the commitments for each project to see
 * if changes have occurred.If any of these changes have occurred,the commitment summary are deleted and recreated.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Commitment Changes
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_COST
 * @rep:category BUSINESS_ENTITY PA_PERF_REPORTING
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/* Commitments_Changed
	Return Y if commitments for the project have changed.
	Return N if commitments for the project have not changed.
*/

/*#
 * This function checks if new commitments have been added or not,a commitment has been fully or partially converted to cost and
 * the status of a commitment has changed from unapproved to approved, if commitments have changed then the function returns a value of
 * Y otherwise returns N.
 * @return Returns the flag indicating if a commitment has changed from unapproved to approved.
 * @param p_ProjectID The identifier for the project.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Commitments Changed
 * @rep:compatibility S
*/
FUNCTION COMMITMENTS_CHANGED ( p_ProjectID IN NUMBER )
	RETURN VARCHAR2 ;
Pragma Restrict_References ( Commitments_Changed, WNDS, WNPS );

END PA_CLIENT_EXTN_CHECK_CMT;

 

/
