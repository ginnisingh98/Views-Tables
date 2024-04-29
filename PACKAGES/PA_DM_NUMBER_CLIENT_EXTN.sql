--------------------------------------------------------
--  DDL for Package PA_DM_NUMBER_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DM_NUMBER_CLIENT_EXTN" AUTHID CURRENT_USER AS
/* $Header: PADMNRXS.pls 120.0.12010000.3 2009/10/21 10:03:32 vchilla noship $ */
/*#
 * Oracle Projects provides a template package that contains a procedure that you can modify to implement
 * Debit memo number generation. The name of the package is pa_dm_number_client_extn. The name of the
 * procedure is get_next_number.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Client Extension for Debit Memo Number Generation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PAYABLE_INV_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * Procedure that can be modified to implement Debit Memo Number Generation
 * @param p_project_id Identifier of the Project (Project_Id)
 * @param p_vendor_id  Identifier of the Vendor (Vendor_Id)
 * @param p_vendor_site_id Vendor Site Id
 * @param p_org_id Org Id
 * @param p_po_header_id PO Header Id
 * @param p_ci_id Control Item Id
 * @param p_dctn_req_date Deduction Request Date
 * @param p_debit_memo_date Debit Memo Date
 * @param p_next_number Debit Memo Number to be returned
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Next Debit Memo Number
 * @rep:compatibility S
*/

PROCEDURE GET_NEXT_NUMBER (
         p_project_id           IN  NUMBER
        ,p_vendor_id            IN  NUMBER
        ,p_vendor_site_id       IN  NUMBER
        ,p_org_id               IN  NUMBER
        ,p_po_header_id         IN  NUMBER
        ,p_ci_id                IN  NUMBER
        ,p_dctn_req_date        IN  DATE
        ,p_debit_memo_date      IN  DATE
        ,p_next_number          IN  OUT NOCOPY VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2);

END;


/
