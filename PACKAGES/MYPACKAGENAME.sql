--------------------------------------------------------
--  DDL for Package MYPACKAGENAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MYPACKAGENAME" AUTHID CURRENT_USER AS
/* $Header: PAXITMPS.pls 120.2 2006/07/04 11:50:11 smaroju noship $ */
/*#
 * This extension contains the procedure that will be called by Oracle Projects for using the billing extensions.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Billing Extensions
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

-- Replace all occurrences of 'MyProcName' in this file with the name of
-- your main procedure.
--
-- *** WARNING! DO NOT CHANGE THE PARAMETERS TO MyProcName ***

/*#
 * This is used as a billing extension procedure template.
 * @param X_project_id Identifier of the billing assignment project
 * @rep:paraminfo {@rep:required}
 * @param X_top_task_id Identifier of the top task of the billing assignment
 * @param X_calling_process Specifies whether the revenue or invoice program is calling the billing extension
 * @param X_calling_place  Specifies whether the billing extension is called in the revenue or invoice program
 * @param X_amount The amount entered on the billing assignment
 * @param X_percentage The percentage entered on the billing assignment
 * @param X_rev_or_bill_date Specifies the accrue through date if called by revenue generation, or the bill
 * through date if called by invoice generation
 * @param X_bill_extn_assignment_id Identifier of the billing assignment that is being processed
 * @param X_bill_extension_id Identifier of the billing extension that is being processed
 * @param X_request_id Request identifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Billing Extension Template
 * @rep:compatibility S
*/
PROCEDURE MyProcName(	X_project_id               IN     NUMBER,
	             	X_top_task_id              IN     NUMBER DEFAULT NULL,
                     	X_calling_process          IN     VARCHAR2 DEFAULT NULL,
                     	X_calling_place            IN     VARCHAR2 DEFAULT NULL,
                     	X_amount                   IN     NUMBER DEFAULT NULL,
                     	X_percentage               IN     NUMBER DEFAULT NULL,
                     	X_rev_or_bill_date         IN     DATE DEFAULT NULL,
                     	X_bill_extn_assignment_id  IN     NUMBER DEFAULT NULL,
                     	X_bill_extension_id        IN     NUMBER DEFAULT NULL,
                     	X_request_id               IN     NUMBER DEFAULT NULL);

END MyPackageName;

 

/
