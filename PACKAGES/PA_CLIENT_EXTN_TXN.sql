--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_TXN" AUTHID CURRENT_USER as
/* $Header: PAXCCETS.pls 120.3 2006/07/25 19:41:03 skannoji noship $ */
/*#
 * Labor transaction extensions enable you to create additional transactions for
 * labor items charged to projects. For example, you can create additional
 * transactions for hazardous work performed for every labor transaction charged to certain projects.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Labor Transaction.
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
* You can use this procedure to add related transactions for source transactions.
* @param x_expenditure_item_id  The identifier of the source transaction.
* @rep:paraminfo {@rep:required}
* @param x_sys_linkage_function The expenditure type class of the source transaction.
* @rep:paraminfo {@rep:required}
* @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Add Related Transactions.
* @rep:compatibility S
*/

  procedure Add_Transactions( x_expenditure_item_id    IN     number,
                              x_sys_linkage_function   IN     varchar2,
                              x_status                 IN OUT NOCOPY number    );

end PA_Client_Extn_Txn;

 

/
