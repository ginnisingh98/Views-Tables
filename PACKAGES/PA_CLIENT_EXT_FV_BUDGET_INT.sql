--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXT_FV_BUDGET_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXT_FV_BUDGET_INT" AUTHID CURRENT_USER AS
/* $Header: PAXFBIES.pls 120.2 2006/12/27 11:22:33 anuagraw noship $ */
/*
 * This extension or a function will be provided to integrate budget lines in projects to
 * open interface tables.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Budget Interface
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:category BUSINESS_ENTITY PA_FORECAST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*
 * This procedure is used to insert Budget Lines into interface tables.
 * @param p_project_id Unique identifier of the project in Oracle Projects.
 * @rep:paraminfo {@rep:required}
 * @param p_pre_baselined_version_id Unique identifier of the budget version
 *        previous to current baseline budget version.
 * @rep:paraminfo {@rep:required}
 * @param p_baselined_budget_version_id Unique identifier of the current baselined
 *        budget version .
 * @rep:paraminfo {@rep:required}
 * @param x_rejection_code identifier of the source of the error and the error message
 *        causing rejecion.
 * @rep:paraminfo {@rep:required}
 * @param x_interface_status identifier of the success status of the budget integration
 *        to open interface tables.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Budget Interface
 * @rep:compatibility S
*/
  PROCEDURE INSERT_BUDGET_LINES
  (  p_project_id                     IN         NUMBER
    ,p_pre_baselined_version_id       IN         NUMBER
    ,p_baselined_budget_version_id    IN         NUMBER
    ,x_rejection_code                 OUT NOCOPY VARCHAR2
    ,x_interface_status               OUT NOCOPY VARCHAR2
  ) ;

end PA_CLIENT_EXT_FV_BUDGET_INT;

/
