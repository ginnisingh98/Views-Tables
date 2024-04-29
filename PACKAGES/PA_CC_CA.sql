--------------------------------------------------------
--  DDL for Package PA_CC_CA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_CA" AUTHID CURRENT_USER AS
/* $Header: PAICPCAS.pls 120.5 2006/07/25 06:41:34 lveerubh noship $ */
/*#
 * This extension is used for cost accrual identification.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Cost Accrual Identification Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_IC_TRANSACTION
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This extension is used to identify cross charged projects that use cost accrual during revenue generation.
 * @param p_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_cost_accrual_flag Flag identifying the cost accrual projects. Value is Y or N
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Identify Cost Accrual Project
 * @rep:compatibility S
*/
      PROCEDURE identify_ca_project
          (  p_project_id               IN    NUMBER,
             x_cost_accrual_flag       OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end pa_cc_ca;

/
