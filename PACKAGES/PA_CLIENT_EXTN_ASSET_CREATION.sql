--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_ASSET_CREATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_ASSET_CREATION" AUTHID CURRENT_USER AS
--$Header: PACCXACS.pls 120.2 2006/07/25 20:41:46 skannoji noship $
/*#
 * You can use this extension to create project assets (capital assets and retirement adjustment assets) and asset assignment
 * automatically prior to the creation of the asset lines based on the transaction data (such as inventory issues and supplier
 * invoices) entered for the data.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Asset Lines Processing Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * You can use this procedure to create project assets prior to the creation of asset lines, based on transaction data.
 * @param p_project_id The Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_asset_date_through Date Placed in Service Through.runtime parameter for the PRC Generate Asset Lines Process
 * @rep:paraminfo {@rep:required}
 * @param p_pa_date_through PA Through Date runtime parameter for the PRC Generate Asset Lines Process. The last day of the PA period through which you want to include costs
 * @param p_capital_event_id Runtime parameter Capital Event Number for the PRC Generate Asset Lines Process. If a value is supplied, only assets and costs associated with a single capital event are processed
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (S = success, F = failure, U = unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data Error message text
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Assets
 * @rep:compatibility S
*/
PROCEDURE CREATE_PROJECT_ASSETS(p_project_id            IN      NUMBER,
                                p_asset_date_through    IN      DATE,
                                p_pa_date_through       IN      DATE DEFAULT NULL,
                                p_capital_event_id      IN      NUMBER DEFAULT NULL,
                                x_return_status    OUT NOCOPY VARCHAR2,
                                x_msg_data         OUT NOCOPY VARCHAR2);

END;

 

/
