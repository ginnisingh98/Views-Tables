--------------------------------------------------------
--  DDL for Package PAROUTINGX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAROUTINGX" AUTHID CURRENT_USER AS
/* $Header: PAXTRTES.pls 120.3 2006/07/29 11:39:59 skannoji noship $ */
/*#
 * This extension is used to define rules for routing timecards and expense reports for approval.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Route To Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

G_dummy Pa_Otc_Api.Timecard_Table;

/*#
 * Use this procedure to define rules for routing timecards and expense reports for approval.
 * @param X_expenditure_id The identifier of the transaction
 * @rep:paraminfo {@rep:required}
 * @param X_incurred_by_person_id The identifier of the person incurring the transaction
 * @rep:paraminfo {@rep:required}
 * @param X_expenditure_end_date Transaction item date
 * @rep:paraminfo {@rep:required}
 * @param X_exp_class_code Expenditure class
 * @rep:paraminfo {@rep:required}
 * @param X_previous_approver_person_id The identifier of the previous approver
 * @param P_Timecard_Table Timecard table
 * @param P_Module Module Application calling this extension
 * @param X_route_to_person_id Identifier of the person selected to approve the transaction
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Route To Extension
 * @rep:compatibility S
*/
  PROCEDURE  route_to_extension (
               X_expenditure_id                  IN NUMBER
            ,  X_incurred_by_person_id           IN NUMBER
            ,  X_expenditure_end_date            IN DATE
            ,  X_exp_class_code                  IN VARCHAR2
	    ,  X_previous_approver_person_id     IN NUMBER DEFAULT NULL
            ,  P_Timecard_Table                  IN Pa_Otc_Api.Timecard_Table DEFAULT PAROUTINGX.G_dummy
	    ,  P_Module                          IN VARCHAR2 DEFAULT NULL
            ,  X_route_to_person_id              OUT NOCOPY NUMBER );

END  PAROUTINGX;
 

/
