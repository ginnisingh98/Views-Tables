--------------------------------------------------------
--  DDL for Package PA_CE_AR_NOTIFY_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CE_AR_NOTIFY_WF" AUTHID CURRENT_USER as
/* $Header: PAPWPCES.pls 120.0.12010000.5 2009/10/21 10:04:05 vchilla noship $ */
/*#
 * Oracle Projects provides a template package that contains a procedure that you can modify to change
 * the logic of selecting the person, to notify, whenever a receipt is applied on an Invoice.
 * The name of the package is pa_ce_ar_notify_wf. The name of the procedure is Select_Project_Manager.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Client Extension for AR Notifications.
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PAYABLE_INV_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * Procedure that can be modified to change project manager selection,
 * @param p_project_id Identifier of the Project (Project_Id)
 * @param p_project_manager_id Person id to be returned
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return of the API (success >= 0/failure < 0/unexpected error < 0)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Select Project Manager
 * @rep:compatibility S
*/

PROCEDURE Select_Project_Manager (p_project_id          IN  NUMBER
                                , p_project_manager_id  OUT NOCOPY NUMBER
                                , p_return_status       IN OUT NOCOPY NUMBER);

END pa_ce_ar_notify_wf;

/
