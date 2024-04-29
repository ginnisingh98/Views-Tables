--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BURDEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BURDEN" AUTHID CURRENT_USER as
/* $Header: PAXCCEBS.pls 120.4 2006/07/25 19:40:39 skannoji noship $ */
/*#
 * You can use this extension to override the burden schedule ID. Oracle Projects calls the burden costing extension during
 * the cost distribution processes.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Burden Costing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_BURDEN_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure assigns a burden cost schedule to a transaction.
 * @param p_transaction_type The transaction type
 * @param p_tran_item_id  The identifier of the transaction
 * @param p_tran_type The transaction type
 * @param p_task_id The identifier of the task
 * @param p_schedule_type The rate schedule type (C = Costing Schedule, R = Revenue Schedule, I = Invoice Schedule)
 * @param p_exp_item_date The expenditure item date
 * @param x_sch_fixed_date The schedule fixed date for firm costing schedules
 * @rep:paraminfo {@rep:required}
 * @param x_rate_sch_rev_id The identifier of the burden schedule revision ID assigned by the extension
 * @rep:paraminfo {@rep:required}
 * @param x_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Override Rate Revision ID
 * @rep:compatibility S
*/
  procedure Override_Rate_Rev_Id(
                           p_transaction_type      in varchar2 DEFAULT 'ACTUAL',
                           p_tran_item_id          in number DEFAULT NULL,
                           p_tran_type             in varchar2 DEFAULT NULL,
                           p_task_id         	   in number DEFAULT NULL,
                           p_schedule_type         IN Varchar2 DEFAULT NULL,
                           p_exp_item_date         IN  Date DEFAULT NULL,
                           x_sch_fixed_date        OUT NOCOPY Date,
                           x_rate_sch_rev_id 	   out NOCOPY number,
                           x_status                out NOCOPY number);
-- This pragma is defined since this procedure will be called from
-- PA_COST_PLUS.find_rate_sch_rev_id which has following pragma
-- This means the Client extension can not change any data and cannot
-- change any global variable
--

-- commenting out since pragma removed from PA_COST_PLUS.find_rate_sch_rev_id bug 3786374
--- pragma RESTRICT_REFERENCES (Override_Rate_Rev_Id, WNDS, WNPS );

end PA_CLIENT_EXTN_BURDEN;

 

/
