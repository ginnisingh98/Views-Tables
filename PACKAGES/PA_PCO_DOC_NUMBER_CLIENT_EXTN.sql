--------------------------------------------------------
--  DDL for Package PA_PCO_DOC_NUMBER_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PCO_DOC_NUMBER_CLIENT_EXTN" AUTHID CURRENT_USER AS
/* $Header: PAPCORXS.pls 120.1.12010000.2 2009/10/21 06:13:52 sosharma noship $ */
/*#
 * Oracle Projects provides a template package that contains a procedure that you
 * can modify to implement Potential Change Order Report document numbering
 * extension. The name of the package is pa_pco_doc_number_client_extn.The
 * name of the procedure is get_next_number.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Potential Change Order Report Document Numbering Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * Procedure that can be modified to implement Potential Change Order
 * Report Document Numbering
 * @param p_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_customer_appr The Customer Approver for Change Request
 * @rep:paraminfo {@rep:required}
 * @param p_change_req_id The Change Request Identifier
 * @rep:paraminfo {@rep:required}
 * @param p_chage_req_ver The Change Request Version
 * @rep:paraminfo {@rep:required}
 * @param p_next_number The Document Number generated
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Return Status:S = Success, E = Error
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count The Error message Count
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data The Error message Data
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Potential Change Order Report Document Numbering Extension
 * @rep:compatibility S
 */

PROCEDURE GET_NEXT_NUMBER (
         p_project_id           IN  NUMBER
        ,p_customer_appr        IN  VARCHAR2
        ,p_change_req_id        IN  NUMBER
        ,p_chage_req_ver        IN  NUMBER
        ,p_next_number          IN  OUT NOCOPY VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2);

END PA_PCO_DOC_NUMBER_CLIENT_EXTN;


/
