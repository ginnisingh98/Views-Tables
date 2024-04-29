--------------------------------------------------------
--  DDL for Package PA_PERF_STATUS_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_STATUS_CLIENT_EXTN" AUTHID CURRENT_USER AS
/* $Header: PAPESCLS.pls 120.5 2006/10/03 09:49:00 sgutha noship $ */
/*#
 * This extension enables you to customize the logic regarding the performance status.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Performance Status
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:category BUSINESS_ENTITY PA_PERF_REPORTING
 * @rep:doccd 120pjapi.pdf See the Oracle Projects APIs, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This function is used to customize the logic in getting the overall performance status.
 * @return The function returns the overall performance of a project.
 * @param p_object_type Type of an Object. PA_PROJECTS is supported for now.
 * @rep:paraminfo {@rep:required}
 * @param p_object_id ID of an object. PROJECT_ID is supported for now.
 * @rep:paraminfo {@rep:required}
 * @param p_kpa_summary List of Key Peformance Area Indicators.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Performance Status
 * @rep:compatibility S
*/

function get_performance_status
	(
	  p_object_type in varchar2
	, p_object_id in number
	, p_kpa_summary  in pa_exception_engine_pkg.summary_table
	 )RETURN VARCHAR2;


end pa_perf_status_client_extn ;

 

/
