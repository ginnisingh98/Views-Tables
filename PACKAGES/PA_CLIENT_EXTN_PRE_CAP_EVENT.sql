--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_PRE_CAP_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_PRE_CAP_EVENT" AUTHID CURRENT_USER AS
--$Header: PACCXCBS.pls 120.1 2006/07/25 20:41:58 skannoji noship $
/*#
 * You can use this extension to create project assets and asset assignments automatically prior to the creation of capital
 * events, based on transaction data entered for the project. Business Entity(ies): Project, Project Capital Asset.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Capital Event Processing Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure contains the logic to create project assets and asset assighments prior to the creation of capital events.
 * When you submit the PRC: Create Periodic Capital Event process, Oracle Projects calls this procedure for each project.
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_event_period_name  Runtime parameter for the PRC: Create Periodic Capital Events Process
 * @rep:paraminfo {@rep:required}
 * @param p_asset_date_through Runtime parameter for the PRC: Create Periodic Capital Events Process
 * @rep:paraminfo {@rep:required}
 * @param p_ei_date_through  Runtime parameter for the PRC: Create Periodic Capital Events Process
 * @param x_return_status API standard: return status of the API (S = success, F = failure, U = unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname PRE Capital Event
 * @rep:compatibility S
*/
PROCEDURE PRE_CAPITAL_EVENT(p_project_id            IN      NUMBER,
                            p_event_period_name     IN      VARCHAR2,
                            p_asset_date_through    IN      DATE,
                            p_ei_date_through       IN      DATE DEFAULT NULL,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_data         OUT NOCOPY VARCHAR2);

END;

 

/
