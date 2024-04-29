--------------------------------------------------------
--  DDL for Package PJI_PJP_SUM_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJP_SUM_CUST" AUTHID CURRENT_USER as
  /* $Header: PJISC01S.pls 120.3 2006/07/27 13:35:34 ajdas noship $ */
/*#
 * This package contains the client extensions for project performance reporting.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Custom Measures Client Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PERF_REPORTING
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
  -- -----------------------------------------------------
  -- procedure PJP_CUSTOM_FPR_API
  -- -----------------------------------------------------
 /*#
  * This procedure is used to implement custom measures in the Financial Planning Reporting
  * Lines Fact table (PJI_FP_XBS_ACCUM_F). The custom measures are used by the summarization
  * program (PRC: Update Project Performance Data and PRC: Load Project Performance Data)
  * to populate the custom measure columns (COLUMN1 through COLUMN15).
  * @param p_worker_id  Identifier of the worker involved in the summarization program
  * @rep:paraminfo {@rep:required}
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Customize Financial Planning Measures
  * @rep:compatibility S
*/
  procedure PJP_CUSTOM_FPR_API (p_worker_id in number);

  -- -----------------------------------------------------
  -- procedure PJP_CUSTOM_ACR_API
  -- -----------------------------------------------------
/*#
 * This procedure is used to implement custom measures in the Activities Reporting Lines
 * Fact table (PJI_AC_XBS_ACCUM_F). The customer measures are used by the summarization
 * programs (PRC: Update Project Performance Data and PRC: Load Project Performance Data)
 * to populate the custom measure columns (COLUMN1 through COLUMN15).
 * @param p_worker_id  Identifier of the worker involved in the summarization program
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Customize Activity Measures
 * @rep:compatibility S
*/
  procedure PJP_CUSTOM_ACR_API (p_worker_id in number);

end PJI_PJP_SUM_CUST;

 

/
