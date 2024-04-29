--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_ASSET_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_ASSET_ALLOC" AUTHID CURRENT_USER AS
--$Header: PACCXAAS.pls 120.1 2006/07/25 20:41:35 skannoji noship $
/*#
 * You can use this extension to define allocation bases for allocating unassigned and common costs across multiple project assets.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Asset Allocation Basis Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * You can use this procedure to define  allocation bases for allocating unassigned and common costs across multiple project assets.
 * @param p_project_asset_line_id Identifier of the project asset line
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_asset_basis_table Array of assets associated with the UNASSIGNED asset line using the grouping level
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (S = success, F = failure, U = unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count The error message count
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data The error message text if there is only one error
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Asset Allocation Basis
 * @rep:compatibility S
*/
PROCEDURE ASSET_ALLOC_BASIS(p_project_asset_line_id IN      NUMBER,
                           p_project_id             IN      NUMBER,
                           p_asset_basis_table      IN OUT NOCOPY PA_ASSET_ALLOCATION_PVT.ASSET_BASIS_TABLE_TYPE,
                           x_return_status             OUT NOCOPY VARCHAR2,
                           x_msg_count                 OUT NOCOPY NUMBER,
                           x_msg_data                  OUT NOCOPY VARCHAR2);

END;

 

/
