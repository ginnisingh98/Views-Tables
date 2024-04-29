--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_PWP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_PWP" AUTHID CURRENT_USER AS
--  $Header: PAPWPEXTS.pls 120.0.12010000.5 2009/10/21 10:04:36 vchilla noship $
/*#
 * Oracle Projects provides a template package that contains a procedure that you can modify to implement
 * Release Pay When Paid Holds extension. The name of the package is (PA_CLIENT_EXTN_PWP) PAPWPEXTB.pls .
 * The name of the procedure is RELEASE_INV.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Release Pay When Paid Holds Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PAYABLE_INV_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*#
* Procedure that can be modified to implement Release Pay When Paid Holds extension
* @param P_REQUEST_ID The request id of concurrent program from which the extension is called
* @rep:paraminfo {@rep:required}
* @param P_PROJECT_TYPE The Project Type for  which release holds program is executed.
* @rep:paraminfo {@rep:required}
* @param P_FROM_PROJ_NUM The starting Project Number for which Release holds program is executed.
* @rep:paraminfo {@rep:required}
* @param P_TO_PROJ_NUM The end Project Number for which Release holds program is executed.
* @rep:paraminfo {@rep:required}
* @param P_CUSTOMER_NAME The Customer Name
* @rep:paraminfo {@rep:required}
* @param P_CUSTOMER_NUMBER The Customer Number
* @rep:paraminfo {@rep:required}
* @param P_REC_DATE_FROM   The date from which receipts are to be considered.
* @rep:paraminfo {@rep:required}
* @param P_REC_DATE_TO The date to which receipts are to be considered.
* @rep:paraminfo {@rep:required}
* @param X_RETURN_STATUS  Return Status
* @rep:paraminfo {@rep:required}
* @param X_ERROR_MESSAGE_CODE  Error Code
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Transaction Control Extension
* @rep:compatibility S
*/



LOG                      NUMBER := 1;

 PROCEDURE     RELEASE_INV (
                        P_REQUEST_ID      IN    NUMBER
                      , P_PROJECT_TYPE    IN  VARCHAR2
                      , P_FROM_PROJ_NUM   IN  VARCHAR2
                      , P_TO_PROJ_NUM     IN  VARCHAR2
                      , P_CUSTOMER_NAME   IN  VARCHAR2
                      , P_CUSTOMER_NUMBER IN  NUMBER
                      , P_REC_DATE_FROM   IN  VARCHAR2
                      , P_REC_DATE_TO     IN  VARCHAR2
                , x_return_status           OUT NOCOPY VARCHAR2
                , x_error_message_code      OUT NOCOPY VARCHAR2);






END PA_CLIENT_EXTN_PWP;

/
